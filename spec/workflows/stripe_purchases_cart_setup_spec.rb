require "rails_helper"

describe StripePurchasesCartSetup, :vcr, :aggregate_failures do
  let(:ticket_1) { instance_spy(
    Ticket, status: "waiting", price: Money.new(1500), id: 1,
            payment_reference: "reference") }
  let(:ticket_2) { instance_spy(
    Ticket, status: "waiting", price: Money.new(1500), id: 2,
            payment_reference: "reference") }
  let(:ticket_3) { instance_spy(Ticket, status: "unsold", id: 3,
                                        payment_reference: "reference") }
  let(:user) { instance_double(
    User, id: 5, tickets_in_cart: [ticket_1, ticket_2], admin?: false) }
  let(:discount_code) { nil }
  let(:discount_code_string) { nil }
  let(:workflow) { StripePurchasesCartSetup.new(
    user: user, purchase_amount_cents: 3000, stripe_token: token,
    expected_ticket_ids: "1 2", payment_reference: "reference",
    discount_code_string: discount_code_string) }

  describe "successful credit card purchase" do
    let(:token) { StripeToken.new(
      credit_card_number: "4242424242424242", expiration_month: "12",
      expiration_year: Time.zone.now.year + 1, cvc: "123") }

    before(:example) do
      allow(DiscountCode).to receive(:find_by)
        .with(code: discount_code_string).and_return(discount_code)
      allow(workflow).to receive(:save).and_return(true)
      expect(workflow).to receive(:on_success)
      workflow.run
    end

    it "is pre-call valid" do
      expect(workflow).to be_pre_purchase_valid
    end

    it "updates the ticket status" do
      expect(ticket_1).to have_received(:make_purchased)
      expect(ticket_2).to have_received(:make_purchased)
      expect(ticket_3).not_to have_received(:make_purchased)
    end

    it "creates a transaction object" do
      expect(workflow.payment).to have_attributes(
        user_id: user.id, price_cents: 3000,
        reference: a_truthy_value, payment_method: "stripe")
      expect(workflow.payment.payment_line_items.size).to eq(2)
    end

    context "with a discount code" do
      let(:discount_code) { instance_double(
        DiscountCode, id: 1, apply_to: Money.new(3000),
                      discount_for: Money.new(1000)) }
      let(:discount_code_string) { "CODE" }

      it "creates a transaction object" do
        expect(workflow.payment).to have_attributes(
          user_id: user.id, price_cents: 3000, discount_cents: 1000,
          reference: a_truthy_value, payment_method: "stripe")
        expect(workflow.payment.payment_line_items.size).to eq(2)
      end
    end

  end

  describe "pre-flight fails" do
    let(:token) { instance_spy(StripeToken) }

    describe "expected price" do
      let(:workflow) { StripePurchasesCartSetup.new(
        user: user, purchase_amount_cents: 2500, stripe_token: token,
        expected_ticket_ids: "1 2", payment_reference: "reference") }

      it "does not payment if the expected price is incorrect" do
        allow(workflow).to receive(:save).and_return(true)
        expect(workflow).to receive(:on_success).never
        expect { workflow.run }.to raise_error(ChargeSetupValidityException)
        expect(workflow).not_to be_pre_purchase_valid
        expect(ticket_1).not_to have_received(:make_purchased)
        expect(ticket_2).not_to have_received(:make_purchased)
        expect(ticket_3).not_to have_received(:make_purchased)
        expect(workflow.payment).to be_nil
      end

      describe "if the user is an admin" do
        let(:user) { instance_double(
          User, id: 5, tickets_in_cart: [ticket_1, ticket_2], admin?: true) }

        before(:example) {
          allow(workflow).to receive(:save).and_return(true)
          expect(workflow).to receive(:on_success)
        }

        it "works with the new price" do
          expect(workflow).to be_pre_purchase_valid
          workflow.run
          expect(ticket_1).to have_received(:make_purchased)
          expect(ticket_2).to have_received(:make_purchased)
          expect(ticket_3).not_to have_received(:make_purchased)
          expect(workflow.payment).to have_attributes(
            user_id: user.id, price_cents: 2500,
            reference: a_truthy_value, payment_method: "stripe")
          expect(workflow.payment.payment_line_items.size).to eq(2)
        end

      end

    end

    describe "expected tickets" do
      let(:workflow) { StripePurchasesCartSetup.new(
        user: user, purchase_amount_cents: 3000, stripe_token: token,
        expected_ticket_ids: "1 3") }

      it "does not payment if the expected tickets are incorrect" do
        allow(workflow).to receive(:save).and_return(true)
        expect(workflow).to receive(:on_success).never
        expect { workflow.run }.to raise_error(ChargeSetupValidityException)

        expect(workflow).not_to be_pre_purchase_valid
        expect(ticket_1).not_to have_received(:make_purchased)
        expect(ticket_2).not_to have_received(:make_purchased)
        expect(ticket_3).not_to have_received(:make_purchased)
        expect(workflow.payment).to be_nil
      end
    end

    describe "database failure" do
      it "does not payment if the database fails" do
        allow(workflow).to receive(:save).and_raise(
          ActiveRecord::RecordNotSaved.new("oops", workflow.payment))
        expect { workflow.run }.to raise_error(ActiveRecord::RecordNotSaved)
      end
    end

  end

end
