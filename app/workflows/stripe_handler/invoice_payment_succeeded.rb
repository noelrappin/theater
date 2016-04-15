module StripeHandler

  class InvoicePaymentSucceeded

    attr_accessor :event, :success, :payment

    def intialize(event)
      @event = event
      @success = false
    end

    def run
      Subscription.transaction do
        return unless event
        subscription.make_active
        subscription.update_end_date
        @payment = Payment.new(
          user_id: user.id, price_cents: invoice.amount, status: "succeeded",
          reference: Payment.generate_reference, payment_method: "stripe",
          response_id: invoice.charge, full_response: charge.to_json)
        payment.payment_line_items.build(
          reference: subscription, price_cents: invoice.amount)
        @success = save
      end
    end

    def save
      subscription.save && payment.save
    end

    def invoice
      @event.data.object
    end

    def subscription
      @subscription ||= Subscription.find_by(remote_id: invoice.subscription)
    end

    def user
      @user ||= User.find_by(stripe_id: invoice.customer)
    end

    def charge
      @charge ||= Stripe::Charge.retrieve(invoice.charge)
    end

  end

end
