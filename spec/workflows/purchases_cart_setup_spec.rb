require "rails_helper"

describe PurchasesCartSetup, :vcr, :aggregate_failures do
  let(:ticket_1) { instance_spy(
    Ticket, status: "waiting", price: Money.new(1500), id: 1) }
  let(:ticket_2) { instance_spy(
    Ticket, status: "waiting", price: Money.new(1500), id: 2) }
  let(:ticket_3) { instance_spy(Ticket, status: "unsold", id: 3) }
  let(:user) { instance_double(
    User, id: 5, tickets_in_cart: [ticket_1, ticket_2]) }
  let(:action) { PurchasesCartSetup.new(
    user: user, purchase_amount_cents: 3000, stripe_token: token,
    expected_ticket_ids: "1 2") }

  describe "successful credit card purchase" do
    let(:token) { StripeToken.new(
      credit_card_number: "4242424242424242", expiration_month: "12",
      expiration_year: Time.zone.now.year + 1, cvc: "123") }

    before(:example) do
      allow(action).to receive(:save).and_return(true)
      expect(action).to receive(:on_success)
      action.run
    end

    it "is pre-call valid" do
      expect(action).to be_pre_charge_valid
    end

    it "updates the ticket status" do
      expect(ticket_1).to have_received(:purchase)
      expect(ticket_2).to have_received(:purchase)
      expect(ticket_3).not_to have_received(:purchase)
    end

    it "creates a transaction object" do
      expect(action.payment).to have_attributes(
        user_id: user.id, price_cents: 3000,
        reference: a_truthy_value, payment_method: "stripe")
      expect(action.payment.payment_line_items.size).to eq(2)
    end

  end

  describe "pre-flight fails" do
    let(:token) { instance_spy(StripeToken) }

    describe "expected price" do
      let(:action) { PurchasesCartSetup.new(
        user: user, purchase_amount_cents: 2500, stripe_token: token,
        expected_ticket_ids: "1 2") }

      it "does not payment if the expected price is incorrect" do
        allow(action).to receive(:save).and_return(true)
        expect(action).to receive(:on_success).never
        expect { action.run }.to raise_error(ChargeSetupValidityException)
        expect(action).not_to be_pre_charge_valid
        expect(ticket_1).not_to have_received(:purchase)
        expect(ticket_2).not_to have_received(:purchase)
        expect(ticket_3).not_to have_received(:purchase)
        expect(action.payment).to be_new_record
      end
    end

    describe "expected tickets" do
      let(:action) { PurchasesCartSetup.new(
        user: user, purchase_amount_cents: 3000, stripe_token: token,
        expected_ticket_ids: "1 3") }

      it "does not payment if the expected tickets are incorrect" do
        allow(action).to receive(:save).and_return(true)
        expect(action).to receive(:on_success).never
        expect { action.run }.to raise_error(ChargeSetupValidityException)
        expect(action).not_to be_pre_charge_valid
        expect(ticket_1).not_to have_received(:purchase)
        expect(ticket_2).not_to have_received(:purchase)
        expect(ticket_3).not_to have_received(:purchase)
        expect(action.payment).to be_new_record
      end
    end

    describe "database failure" do
      it "does not payment if the database fails" do
        allow(action).to receive(:save).and_raise(
          ActiveRecord::RecordNotSaved.new("oops", action.payment))
        expect { action.run }.to raise_error(ActiveRecord::RecordNotSaved)
      end
    end

  end

end
