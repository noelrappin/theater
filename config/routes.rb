Rails.application.routes.draw do
  root to: 'visitors#index'

  namespace :admin do
    resources :users
    resources :events
    resources :payments
    resources :payment_line_items
    resources :performances
    resources :plans
    resources :subscriptions
    resources :tickets
    root to: "users#index"
  end

  devise_for :users
  resources :events
  resource :shopping_cart
  resource :subscription_cart
  resources :users
  resources :payments
  resources :plans
  resources :subscriptions
  resources :refund
  resources :discount_codes

  get "paypal/approved", to: "pay_pal_payments#approved"

  # START: stripe
  post "stripe/webhook", to: "stripe_webhook#action"
  # END: stripe
end
