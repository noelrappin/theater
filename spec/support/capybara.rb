require "capybara/poltergeist"
require "capybara-screenshot/rspec"
Capybara.asset_host = "http://localhost:3000"
options = {js_errors: false}
Capybara.javascript_driver = :poltergeist_billy
