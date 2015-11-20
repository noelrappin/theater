require "rails_helper"

describe PurchasesCart do

  describe "successful credit card purchase" do
    let(:user) { instance_double(User) }
    let(:action) { PurchasesCart.new(
      user: user, purchase_amount_cents: 3000, stripe_token: "tk_fake_token") }
    let(:ticket_1) { instance_spy(
      Ticket, status: "waiting", user: user, price: Money.new(1500), id: 1) }
    let(:ticket_2) { instance_spy(
      Ticket, status: "waiting", user: user, price: Money.new(1500), id: 2) }
    let(:ticket_3) { instance_spy(Ticket, status: "unsold", id: 3) }

    before(:example) do
      allow(user).to receive(:tickets_in_cart).and_return([ticket_1, ticket_2])
      allow(user).to receive(:id).and_return(5)
      allow(Order).to receive(:generate_reference).and_return("fred")
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
        user_id: user.id, price_cents: 3000, status: "successful",
        reference: "fred", payment_method: "stripe")
      expect(action.order.order_line_items.size).to eq(2)
    end

    it "calls the gateway" do

    end

    it "returns success" do
      expect(action.success).to be_truthy
    end

  end

end
