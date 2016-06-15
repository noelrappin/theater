require "rails_helper"

describe CashPurchasesCart, :aggregate_failures do

  describe "successful credit card purchase" do
    let(:ticket_1) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 1,
              payment_reference: "reference") }
    let(:ticket_2) { instance_spy(
      Ticket, status: "waiting", price: Money.new(1500), id: 2,
              payment_reference: "reference") }
    let(:ticket_3) { instance_spy(Ticket, status: "unsold", id: 3) }
    let(:user) { instance_double(
      User, id: 5, tickets_in_cart: [ticket_1, ticket_2]) }
    let(:discount_code) { nil }
    let(:discount_code_string) { nil }
    let(:workflow) { CashPurchasesCart.new(
      user: user,
      purchase_amount_cents: 3000,
      expected_ticket_ids: "1 2",
      payment_reference: "reference",
      discount_code_string: discount_code_string) }

    context "with an administrative user" do
      before(:example) do
        allow(user).to receive(:admin?).and_return(true)
        allow(DiscountCode).to receive(:find_by)
          .with(code: discount_code_string).and_return(discount_code)
        allow(workflow).to receive(:save).and_return(true)
        workflow.run
      end

      it "updates the ticket status" do
        expect(ticket_1).to have_received(:make_purchased)
        expect(ticket_2).to have_received(:make_purchased)
        expect(ticket_3).not_to have_received(:make_purchased)
      end

      it "creates a transaction object" do
        expect(workflow.payment).to have_attributes(
          user_id: user.id, price_cents: 3000,
          reference: a_truthy_value, payment_method: "cash",
          status: "succeeded", administrator_id: user.id)
        expect(workflow.payment.payment_line_items.size).to eq(2)
      end

      it "returns success" do
        expect(workflow.success?).to be_truthy
      end
    end

    context "with a regular user" do

      before(:example) do
        allow(user).to receive(:admin?).and_return(false)
      end

      it "fails" do
        expect { workflow.run }.to raise_error(UnauthorizedPurchaseException)
        expect(workflow.success?).to be_falsy
        expect(workflow.payment).to be_nil
        expect(ticket_1).not_to have_received(:make_purchased)
        expect(ticket_2).not_to have_received(:make_purchased)
        expect(ticket_3).not_to have_received(:make_purchased)
      end

    end

  end

end
