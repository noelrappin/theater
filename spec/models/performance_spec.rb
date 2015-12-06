require "rails_helper"

RSpec.describe Performance, type: :model do

  describe "finders" do
    let(:performance) { create(:performance) }
    let(:unsold_ticket) { create(:ticket,
                                 status: "unsold", performance: performance) }
    let(:sold_ticket) { create(:ticket,
                               status: "sold", performance: performance) }

    it "can find unsold tickets" do
      expect(performance.unsold_tickets(1)).to eq([unsold_ticket])
    end
  end
end
