Rails.application.routes.draw do
  namespace :braintree do
    resources :payment_method_nonces, only: :create
  end
end
