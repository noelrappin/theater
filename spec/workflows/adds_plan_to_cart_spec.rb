require "rails_helper"

RSpec.describe AddsPlanToCart do

  let(:user) { create(:user) }
  let(:plan) { create(:plan) }
  let(:action) { AddsPlanToCart.new(user: user, plan: plan) }

  describe "happy path adding plans" do
    it "adds a ticket to a cart" do
      action.run
      expect(action).to be_a_success
      expect(action.result).to have_attributes(
        user: user, plan: plan, start_date: Time.zone.today.to_date,
        end_date: 1.month.from_now.to_date)
      expect(action.result).to be_waiting
    end
  end

end
