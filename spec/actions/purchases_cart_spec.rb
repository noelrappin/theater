require "rails_helper"

describe PurchasesCart, :vcr do

  describe "successful credit card purchase" do
    let(:ticket_1) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 1) }
    let(:ticket_2) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 2) }
    let(:ticket_3) { instance_spy(Ticket, status: "unsold", id: 3) }
    let(:user) { instance_double(User, id: 5, tickets_in_cart: [ticket_1, ticket_2]) }
    let(:token) { StripeToken.new(
      credit_card_number: "4242424242424242", expiration_month: "12",
      expiration_year: Time.zone.now.year + 1, cvc: "123") }
    let(:action) { PurchasesCart.new(
      user: user, purchase_amount_cents: 3000, stripe_token: token) }

    before(:example) do
      allow(action).to receive(:save).and_return(true)
      action.run
    end

    it "updates the ticket status" do
      expect(ticket_1).to have_received(:purchase)
      expect(ticket_2).to have_received(:purchase)
      expect(ticket_3).not_to have_received(:purchase)
    end

    it "creates a transaction object" do
      expect(action.order).to have_attributes(
        user_id: user.id, price_cents: 3000,
        reference: a_truthy_value, payment_method: "stripe")
      expect(action.order.order_line_items.size).to eq(2)
    end

    it "takes the response from the gateway" do
      expect(action.order).to have_attributes(
        status: "succeeded", response_id: a_string_starting_with("ch_"),
        full_response: JSON.parse(action.stripe_charge.to_json))
    end

    it "returns success" do
      expect(action.success).to be_truthy
    end

  end

end
