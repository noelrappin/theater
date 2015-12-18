require "rails_helper"

# START: describe_with_js
describe "purchasing a cart", :js, :vcr do
  # END: describe_with_js
  fixtures :all

  it "can add a purchase to a cart" do
    tickets(:midsummer_bums_1).place_in_cart_for(users(:buyer))
    tickets(:midsummer_bums_2).place_in_cart_for(users(:buyer))
    login_as(users(:buyer), scope: :user)
    visit shopping_cart_path
    fill_in :credit_card_number, with: "4242 4242 4242 4242"
    fill_in :expiration_date, with: "12 / #{Time.current.year + 1}"
    fill_in :cvc, with: "123"
    click_on "purchase"
    expect(page).to have_selector(".purchased_ticket", count: 2)
    expect(page).to have_selector(
      "#purchased_ticket_#{tickets(:midsummer_bums_1).id}")
    expect(page).to have_selector(
      "#purchased_ticket_#{tickets(:midsummer_bums_2).id}")
  end

end
