require "rails_helper"

RSpec.describe Order, type: :model do

  describe "generate_reference" do

    before(:example) do
      allow(SecureRandom).to receive(:hex).and_return("first", "second")
    end

    it "generates a reference" do
      expect(Order.generate_reference).to eq("first")
    end

    it "avoids duplicates" do
      create(:order, reference: "first")
      expect(Order.generate_reference).to eq("second")
    end

  end

end
