require "rails_helper"

describe AddsToCart do

  let(:user) { instance_double(User) }
  let(:performance) { instance_double(Performance) }
  let!(:ticket_1) { instance_spy(Ticket, status: "unsold") }
  let!(:ticket_2) { instance_spy(Ticket, status: "unsold") }

  describe "happy path adding tickets" do
    it "adds a ticket to a cart" do
      expect(performance).to receive(:unsold_tickets).with(1).and_return([ticket_1])
      action = AddsToCart.new(user: user, performance: performance, count: 1)
      action.run
      expect(ticket_1).to have_received(:waiting_for).with(user)
      expect(ticket_2).not_to have_received(:waiting_for)
    end
  end

  describe "if there are no tickets, the action fails" do
    it "does not add a ticket to the cart" do
      expect(performance).to receive(:unsold_tickets).with(1).and_return([])
      action = AddsToCart.new(user: user, performance: performance, count: 1)
      action.run
      expect(action.result).to be_falsy
      expect(ticket_1).not_to have_received(:waiting_for)
      expect(ticket_2).not_to have_received(:waiting_for)
    end
  end

end
