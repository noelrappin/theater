require "rails_helper"

describe PurchasesCart do

  describe "successful credit card purchase" do
    let(:ticket_1) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 1) }
    let(:ticket_2) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 2) }
    let(:ticket_3) { instance_spy(Ticket, status: "unsold", id: 3) }
    let(:user) { instance_double(User,
                                 id: 5, tickets_in_cart: [ticket_1, ticket_2]) }
    let(:action) { PurchasesCart.new(
      user: user, purchase_amount_cents: 3000,
      stripe_token: instance_spy(StripeToken, token: "tk_not_a_real_token")) }
    let(:charge) { double(id: "ch_not_an_id", status: "succeeded") }

    before(:example) do
      allow(Order).to receive(:generate_reference).and_return("fred")
      allow(action).to receive(:save).and_return(true)
      allow(StripeCharge).to receive(:charge).and_return(charge)
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
        reference: "fred", payment_method: "stripe")
      expect(action.order.order_line_items.size).to eq(2)
    end

    it "takes the response from the gateway" do
      expect(action.order).to have_attributes(
        status: "succeeded", response_id: "ch_not_an_id",
        full_response: JSON.parse(charge.to_json))
    end

    it "returns success" do
      expect(action.success).to be_truthy
    end

  end

end
