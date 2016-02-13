require "rails_helper"

describe StripePurchasesCart, :vcr, :aggregate_failures do

  describe "successful credit card purchase" do
    let(:ticket_1) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 1) }
    let(:ticket_2) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 2) }
    let(:ticket_3) { instance_spy(Ticket, status: "unsold", id: 3) }
    let(:user) { instance_double(User,
                                 id: 5, tickets_in_cart: [ticket_1, ticket_2]) }
    let(:token) { StripeToken.new(
      credit_card_number: "4242424242424242", expiration_month: "12",
      expiration_year: Time.zone.now.year + 1, cvc: "123") }
    let(:workflow) { StripePurchasesCart.new(
      user: user, purchase_amount_cents: 3000, stripe_token: token) }

    before(:example) do
      allow(workflow).to receive(:save).and_return(true)
      workflow.run
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

    it "takes the response from the gateway" do
      expect(workflow.payment).to have_attributes(
        status: "succeeded", response_id: a_string_starting_with("ch_"),
        full_response: JSON.parse(workflow.stripe_charge.to_json))
    end

    it "returns success" do
      expect(workflow.success).to be_truthy
    end

  end

end
