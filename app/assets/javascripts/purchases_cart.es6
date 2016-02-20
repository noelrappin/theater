class CheckoutForm {

  form() { return $("#payment-form"); }

  button() { return this.form().find(".btn"); }

  disableButton() { this.button().prop("disabled", true); }

  // # START: checkout_form
  paymentTypeRadio() { return $(".payment-type-radio"); }

  selectedPaymentType() {return $("input[name=payment_type]:checked").val(); }

  creditCardForm() { return $("#credit-card-info"); }

  isPayPal() { return this.selectedPaymentType() === "paypal"; }

  setCreditCardVisibility() {
    this.creditCardForm().toggleClass("hidden", this.isPayPal());
  }
  // # END: checkout_form

  submit() { this.form().get(0).submit(); }

  appendHidden(name, value) {
    let field = $("<input>").attr("type", "hidden")
      .attr("name", name).val(value);
    this.form().append(field);
  }
}
// # END: checkout_form

// # START: token_handler
class TokenHandler {
  static handle(status, response) {
    new TokenHandler(status, response).handle();
  }

  constructor(status, response) {
    this.checkoutForm = new CheckoutForm();
    this.status = status;
    this.response = response;
  }

  handle() {
    this.checkoutForm.appendHidden("stripe_token", this.response.id);
    this.checkoutForm.submit();
  }
}
// # END: token_handler

// # START: payment_form_handler
class PaymentFormHandler {

  constructor() {
    this.checkoutForm = new CheckoutForm();
    this.initSubmitHandler();
    this.initPaymentTypeHandler();
  }

  initSubmitHandler() {
    this.checkoutForm.form().submit(event => {
      if (!this.checkoutForm.isPayPal()) {
        this.handleSubmit(event);
      }
    });
  }

  initPaymentTypeHandler() {
    this.checkoutForm.paymentTypeRadio().click(() => {
      this.checkoutForm.setCreditCardVisibility();
    });
  }

  handleSubmit(event) {
    event.preventDefault();
    this.checkoutForm.disableButton();
    Stripe.card.createToken(this.checkoutForm.form(), TokenHandler.handle);
    return false;
  }
}

$(() => { return new PaymentFormHandler(); });
// # END: payment_form_handler
