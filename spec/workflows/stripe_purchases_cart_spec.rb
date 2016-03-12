# require "rails_helper"

# describe StripePurchasesCart, :vcr, :aggregate_failures do

#   let(:workflow) { StripePurchasesCart.new(
#     user: user, purchase_amount_cents: 3000, stripe_token: token,
#     expected_ticket_ids: "1 2", payment_reference: "reference") }
#   let(:user) { instance_double(
#     User, id: 5, tickets_in_cart: [ticket_1, ticket_2]) }
#   let(:ticket_1) { instance_spy(
#     Ticket, status: "waiting", price: Money.new(1500), id: 1,
#             payment_reference: "reference") }
#   let(:ticket_2) { instance_spy(
#     Ticket, status: "waiting", price: Money.new(1500), id: 2,
#             payment_reference: "reference") }
#   let(:ticket_3) { instance_spy(Ticket, status: "unsold", id: 3) }

#   describe "successful credit card purchase" do
#     let(:token) { StripeToken.new(
#       credit_card_number: "4242424242424242", expiration_month: "12",
#       expiration_year: Time.zone.now.year + 1, cvc: "123") }

#     before(:example) do
#       allow(workflow).to receive(:save).and_return(true)
#       workflow.run
#     end

#     it "updates the ticket status" do
#       expect(ticket_1).to have_received(:make_purchased)
#       expect(ticket_2).to have_received(:make_purchased)
#       expect(ticket_3).not_to have_received(:make_purchased)
#     end

#     it "creates a transaction object" do
#       expect(workflow.payment).to have_attributes(
#         user_id: user.id, price_cents: 3000,
#         reference: a_truthy_value, payment_method: "stripe")
#       expect(workflow.payment.payment_line_items.size).to eq(2)
#     end

#     it "takes the response from the gateway" do
#       expect(workflow.payment).to have_attributes(
#         status: "succeeded", response_id: a_string_starting_with("ch_"),
#         full_response: JSON.parse(workflow.stripe_charge.response.to_json))
#     end

#     it "returns success" do
#       expect(workflow.success).to be_truthy
#     end

#   end

#   # START: failed_credit_card
#   describe "an unsuccessful credit card purchase" do
#     let(:token) { StripeToken.new(
#       credit_card_number: "4000000000000002", expiration_month: "12",
#       expiration_year: Time.zone.now.year + 1, cvc: "123") }

#     before(:example) do
#       allow(workflow).to receive(:save).and_return(true)
#       workflow.run
#     end

#     it "updates the ticket status" do
#       expect(ticket_1).to have_received(:make_purchased)
#       expect(ticket_2).to have_received(:make_purchased)
#       expect(ticket_3).not_to have_received(:make_purchased)
#       expect(ticket_1).to have_received(:return_to_cart)
#       expect(ticket_2).to have_received(:return_to_cart)
#       expect(ticket_3).not_to have_received(:return_to_cart)
#     end

#     it "creates a transworkflow object" do
#       expect(workflow.payment).to have_attributes(
#         user_id: user.id, price_cents: 3000,
#         reference: a_truthy_value, payment_method: "stripe")
#       expect(workflow.payment.payment_line_items.size).to eq(2)
#     end

#     it "takes the response from the gateway" do
#       expect(workflow.payment).to have_attributes(
#         status: "failed", response_id: nil,
#         full_response: JSON.parse(workflow.stripe_charge.error.to_json))
#     end

#     it "returns failure" do
#       expect(workflow.success).to be_falsy
#     end
#   end
#   # END: failed_credit_card

#   describe "pre-flight fails" do
#     let(:token) { instance_spy(StripeToken) }

#     describe "expected price" do
#       let(:workflow) { StripePurchasesCart.new(
#         user: user, purchase_amount_cents: 2500, stripe_token: token,
#         expected_ticket_ids: "1 2") }

#       it "does not payment if the expected price is incorrect" do
#         allow(workflow).to receive(:save).and_return(true)
#         workflow.run
#         expect(workflow).not_to be_pre_purchase_valid
#         expect(ticket_1).not_to have_received(:make_purchased)
#         expect(ticket_2).not_to have_received(:make_purchased)
#         expect(ticket_3).not_to have_received(:make_purchased)
#         expect(workflow.success).to be_falsy
#         expect(workflow.payment).to be_nil
#       end
#     end

#     describe "expected tickets" do
#       let(:workflow) { StripePurchasesCart.new(
#         user: user, purchase_amount_cents: 3000, stripe_token: token,
#         expected_ticket_ids: "1 3") }

#       it "does not payment if the expected tickets are incorrect" do
#         allow(workflow).to receive(:save).and_return(true)
#         workflow.run
#         expect(workflow).not_to be_pre_purchase_valid
#         expect(ticket_1).not_to have_received(:make_purchased)
#         expect(ticket_2).not_to have_received(:make_purchased)
#         expect(ticket_3).not_to have_received(:make_purchased)
#         expect(workflow.success).to be_falsy
#         expect(workflow.payment).to be_nil
#       end
#     end

#     # START: database_failure
#     describe "database failure" do
#       it "does not payment if the database fails" do
#         expect(StripeCharge).to receive(:new).never
#         allow(workflow).to receive(:save).and_return(false)
#         workflow.run
#         expect(workflow.success).to be_falsy
#       end
#     end
#     # END: database_failure
#   end
# end
