Rails.application.routes.draw do

  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :product_types do
    resources :products
  end

  resources :inventories, only: [:index, :show]
  resource :sale, only: [:show]
end
