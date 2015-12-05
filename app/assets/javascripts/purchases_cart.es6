class CheckoutForm {

  form() { return $("#order-form"); }

  button() { return this.form().find(".btn"); }

  disableButton() { this.button().prop("disabled", true); }

  submit() { this.form().get(0).submit(); }

  appendHidden(name, value) {
    let field = $("<input>").attr("type", "hidden")
      .attr("name", name).val(value);
    this.form().append(field);
  }
}

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

class StripeForm {

  constructor() {
    this.checkoutForm = new CheckoutForm();
    this.initSubmitHandler();
  }

  initSubmitHandler() {
    this.checkoutForm.form().submit((event) => { this.handleSubmit(event); });
  }

  handleSubmit(event) {
    event.preventDefault();
    this.checkoutForm.disableButton();
    Stripe.card.createToken(this.checkoutForm.form(), TokenHandler.handle);
    return false;
  }
}

$(() => { return new StripeForm(); });
