require "rails_helper"

describe StripeCharge, :vcr do

  let(:order) { build_stubbed(
    Order, price: Money.new(3000), reference: Order.generate_reference) }

  describe "success", :aggregate_failures do

    let(:token) { StripeToken.new(
      credit_card_number: "4242424242424242", expiration_month: "12",
      expiration_year: Time.zone.now.year + 1, cvc: "123") }

    it "calls stripe to get a charge" do
      charge = StripeCharge.new(token: token, order: order)
      charge.charge
      expect(charge.response.id).to start_with("ch")
      expect(charge.response.amount).to eq(3000)
      expect(charge).to be_a_success
    end

  end

  describe "failure" do

    let(:token) { StripeToken.new(
      credit_card_number: "4000000000000002", expiration_month: "12",
      expiration_year: Time.zone.now.year + 1, cvc: "123") }

    it "handles failure" do
      charge = StripeCharge.new(token: token, order: order)
      charge.charge
      expect(charge.response).to be_nil
      expect(charge).not_to be_a_success
    end
  end
end
