Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users
  resources :events
  resource :shopping_cart
  resource :subscription_cart
  resources :users
  resources :payments
  resources :plans
  resources :subscriptions

  get "paypal/approved", to: "pay_pal_payments#approved"

  # START: stripe
  post "stripe/webhook", to: "stripe_webhook#action"
  # END: stripe
end
