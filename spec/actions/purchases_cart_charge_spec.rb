require "rails_helper"

describe PurchasesCartCharge, :vcr, :aggregate_failures do
  let(:user) { instance_double(User, id: 5) }
  let(:order) { Order.new(user_id: user.id,
                          price_cents: 2500, status: "created",
                          reference: Order.generate_reference,
                          payment_method: "stripe") }
  let(:action) { PurchasesCartCharge.new(order, token.id) }

  describe "successful credit card purchase" do
    let(:token) { StripeToken.new(
      credit_card_number: "4242424242424242", expiration_month: "12",
      expiration_year: Time.zone.now.year + 1, cvc: "123") }

    before(:example) do
      allow(action).to receive(:save).and_return(true)
      action.run
    end

    it "takes the response from the gateway" do
      expect(action.order).to have_attributes(
        status: "succeeded", response_id: a_string_starting_with("ch_"),
        full_response: JSON.parse(action.stripe_charge.response.to_json))
    end

  end

  describe "an unsuccessful credit card purchase" do
    let(:token) { StripeToken.new(
      credit_card_number: "4000000000000002", expiration_month: "12",
      expiration_year: Time.zone.now.year + 1, cvc: "123") }

    before(:example) do
      allow(action).to receive(:save).and_return(true)
      expect(action).to receive(:unpurchase_tickets)
      action.run
    end

    it "takes the response from the gateway" do
      expect(action.order).to have_attributes(
        status: "failed", response_id: nil,
        full_response: JSON.parse(action.stripe_charge.error.to_json))
    end
  end

end
