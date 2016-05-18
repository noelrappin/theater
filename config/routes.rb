Rails.application.routes.draw do
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
