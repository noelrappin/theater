require "rails_helper"

RSpec.describe Ticket, type: :model do

  it "can move to waiting" do
    user = create(:user)
    ticket = create(:ticket, status: "unsold")
    ticket.place_in_cart_for(user)
    expect(ticket.user).to eq(user)
    expect(ticket.status).to eq("waiting")
  end

  it "can move to purchased" do
    user = create(:user)
    ticket = create(:ticket, status: "waiting", user: user)
    ticket.make_purchased
    expect(ticket.user).to eq(user)
    expect(ticket.status).to eq("purchased")
  end

  it "can move back to cart" do
    user = create(:user)
    ticket = create(:ticket, status: "purchased", user: user)
    ticket.return_to_cart
    expect(ticket.user).to eq(user)
    expect(ticket.status).to eq("waiting")
  end
end
