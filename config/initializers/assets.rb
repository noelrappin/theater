# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"
Rails.application.config.assets.precompile +=
  %w(support/phantomjs-shims.self.js jquery.self.js jquery_ujs.self.js
     jquery.payment.self.js turbolinks.self.js bootstrap/affix.self.js
     bootstrap/alert.self.js bootstrap/button.self.js
     bootstrap/carousel.self.js bootstrap/collapse.self.js
     bootstrap/dropdown.self.js bootstrap/modal.self.js
     bootstrap/scrollspy.self.js bootstrap/tab.self.js
     bootstrap/transition.self.js bootstrap/tooltip.self.js
     bootstrap/popover.self.js bootstrap-sprockets.self.js
     purchases_cart.self.js application.self.js spec_helper.self.js
     foo_spec.self.js)

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are
# already added.
# Rails.application.config.assets.precompile += %w( search.js )
