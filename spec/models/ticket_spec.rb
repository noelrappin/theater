require "rails_helper"

RSpec.describe Ticket, type: :model do

  it "can move to waiting" do
    user = build_stubbed(:user)
    ticket = create(:ticket, status: "unsold")
    ticket.place_in_cart_for(user)
    expect(ticket.user).to eq(user)
    expect(ticket.status).to eq("waiting")
  end
end
