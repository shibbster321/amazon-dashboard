Rails.application.routes.draw do
  get 'inventory',  to: "pages#inventory"
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :product_types do
    resources :products
  end


end
