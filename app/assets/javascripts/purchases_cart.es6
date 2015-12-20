class CheckoutForm {

  // # START: checkout_form_format
  format() {
    this.numberField().payment("formatCardNumber");
    this.expiryField().payment("formatCardExpiry");
    this.cvcField().payment("formatCardCVC");
    this.disableButton();
  }
  // # END: checkout_form_format

  // # START: checkout_form_valid_fields
  form() { return $("#order-form"); }

  validFields() { return this.form().find(".valid-field");}

  numberField() { return this.form().find("#credit_card_number"); }

  expiryField() { return this.form().find("#expiration_date"); }

  cvcField() { return this.form().find("#cvc"); }
  // # END: checkout_form_valid_fields

  valid() {
    return this.isNumberValid() && this.isExpiryValid() && this.isCvcValid();
  }

  isNumberValid() {
    return $.payment.validateCardNumber(this.numberField().val());
  }

  isExpiryValid() {
    const date = $.payment.cardExpiryVal(this.expiryField().val());
    return $.payment.validateCardExpiry(date.month, date.year);
  }

  isCvcValid() { return $.payment.validateCardCVC(this.cvcField().val());}

  displayFieldStatus(field, valid) {
    if (field.val() === "") {
      return;
    }
    const parent = field.parents(".form-group");
    parent.toggleClass("has-error", !valid);
    parent.toggleClass("has-success", valid);
  }

  cardType() {return $.payment.cardType(this.numberField().val()) || "credit"; }

  imageUrl() {return `/assets/creditcards/${this.cardType()}.png`; }

  cardImage() { return $("#card-image"); }

  displayStatus() {
    this.displayFieldStatus(this.numberField(), this.isNumberValid());
    this.displayFieldStatus(this.expiryField(), this.isExpiryValid());
    this.displayFieldStatus(this.cvcField(), this.isCvcValid());
    this.cardImage().attr("src", this.imageUrl());
    this.buttonStatus();
  }

  button() { return this.form().find(".btn"); }

  disableButton() { this.button().toggleClass("disabled", true); }

  enableButton() { this.button().toggleClass("disabled", false); }

  buttonStatus() { this.valid() ? this.enableButton() : this.disableButton(); }

  isEnabled() { return !this.button().hasClass("disabled"); }

  submit() { this.form().get(0).submit(); }

  appendHidden(name, value) {
    let field = $("<input>")
      .attr("type", "hidden")
      .attr("name", name)
      .val(value);
    this.form().append(field);
  }

  errorText() { return this.form.find("#error-text"); }

  appendError(text) { this.errorText().text(text); }

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

  isError() { return this.response.error; }

  handle() {
    if (this.isError()) {
      this.checkoutForm.appendError(this.response.error.message);
      this.checkoutForm.enableButton();
    } else {
      this.checkoutForm.appendHidden("stripe_token", this.response.id);
      this.checkoutForm.submit();
    }
  }
}
// # END: token_handler

class StripeForm {

  // # START: stripe_form_constructor
  constructor() {
    this.checkoutForm = new CheckoutForm();
    this.checkoutForm.format();
    this.initEventHandlers();
  }
  // # END: stripe_form_constructor

  // # START: stripe_form_event_handlers
  initEventHandlers() {
    this.checkoutForm.form().submit((event) => this.handleSubmit(event));
    this.checkoutForm.validFields().keyup(() => {
      this.checkoutForm.displayStatus();
    });
  }
  // # END: stripe_form_event_handlers

  handleSubmit(event) {
    event.preventDefault();
    if (!this.checkoutForm.isEnabled()) {
      return false;
    }
    this.checkoutForm.disableButton();
    Stripe.card.createToken(this.checkoutForm.form(), TokenHandler.handle);
    return false;
  }
}


// # START: jQuery
$(() => {
  if ($(".credit-card-form").size() > 0) {
    return new StripeForm();
  }
});
// # END: jQuery
