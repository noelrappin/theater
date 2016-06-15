require "rails_helper"

describe PayPalPurchasesCart, :vcr, :aggregate_failures do

  describe "successful credit card purchase" do
    let(:ticket_1) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 1,
              payment_reference: "reference") }
    let(:ticket_2) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 2,
              payment_reference: "reference") }
    let(:ticket_3) { instance_spy(Ticket, status: "unsold", id: 3) }
    let(:user) { instance_double(
      User, id: 5, tickets_in_cart: [ticket_1, ticket_2], admin?: false) }
    let(:discount_code) { nil }
    let(:discount_code_string) { nil }
    let(:workflow) { PayPalPurchasesCart.new(
      user: user,
      purchase_amount_cents: 3000,
      expected_ticket_ids: "1 2",
      payment_reference: "reference",
      discount_code_string: discount_code_string) }

    before(:example) do
      allow(DiscountCode).to receive(:find_by)
        .with(code: discount_code_string).and_return(discount_code)
      allow(workflow).to receive(:save).and_return(true)
      workflow.run
    end

    it "updates the ticket status" do
      expect(ticket_1).to have_received(:make_pending)
      expect(ticket_2).to have_received(:make_pending)
      expect(ticket_3).not_to have_received(:make_pending)
    end

    it "creates a transaction object" do
      expect(workflow.payment).to have_attributes(
        user_id: user.id, price_cents: 3000,
        reference: a_truthy_value, payment_method: "paypal")
      expect(workflow.payment.payment_line_items.size).to eq(2)
    end

    it "generates a redirect url" do
      expect(workflow.redirect_on_success_url).to start_with(
        "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout")
      expect(workflow.payment.response_id).to eq(
        workflow.pay_pal_payment.pay_pal_payment.id)
    end

    it "returns success" do
      expect(workflow.success?).to be_truthy
    end

    context "with a discount code" do
      let(:discount_code) { instance_double(
        DiscountCode, id: 1, apply_to: Money.new(3000),
                      discount_for: Money.new(1000)) }
      let(:discount_code_string) { "CODE" }

      it "creates a transaction object" do
        expect(workflow.payment).to have_attributes(
          user_id: user.id, price_cents: 3000, discount_cents: 1000,
          reference: a_truthy_value, payment_method: "paypal")
        expect(workflow.payment.payment_line_items.size).to eq(2)
      end
    end

  end

end
