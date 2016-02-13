// # START: checkout_form
class CheckoutForm {

  form() { return $("#payment-form"); }

  button() { return this.form().find(".btn"); }

  disableButton() { this.button().prop("disabled", true); }

  paymentTypeRadio() { return $(".payment-type-radio"); }

  selectedPaymentType() {return $("input[name=payment_type]:checked").val(); }

  creditCardForm() { return $("#credit-card-info"); }

  setCreditCardVisibility() {
    this.creditCardForm().toggleClass(
      "hidden", this.selectedPaymentType() === "paypal");
  }

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

// # START: stripe_form
class StripeForm {

  constructor() {
    this.checkoutForm = new CheckoutForm();
    this.initSubmitHandler();
    this.initPaymentTypeHandler();
  }

  initSubmitHandler() {
    this.checkoutForm.form().submit(event => { this.handleSubmit(event); });
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
// # END: stripe_form


// # START: jQuery
$(() => { return new StripeForm(); });
// # END: jQuery
