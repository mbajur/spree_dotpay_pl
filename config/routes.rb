Spree::Core::Engine.routes.draw do
  resources :dotpay_callbacks, :only => [:create]

  namespace :gateway do
    get 'dotpay/complete/:number' => 'dotpay#complete', as: :dotpay_complete
    get 'dotpay/:gateway_id/:order_id' => 'dotpay#show', as: :dotpay
    post 'dotpay/comeback' => 'dotpay#comeback', as: :dotpay_comeback
  end
end
