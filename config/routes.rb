Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users
  resources :events
  resource :shopping_cart
  resources :users
  resources :payments

  get "paypal/approved", to: "pay_pal_payments#approved"
end
