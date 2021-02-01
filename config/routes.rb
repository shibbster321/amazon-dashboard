Rails.application.routes.draw do

  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :product_types do
    get '/inventories/', to: 'inventories#subindex', as: 'inventories'
    get '/sales/', to: 'sales#subindex', as: 'sales'
    resources :products
  end

  resources :inventories, only: [:index]
  resources :sales, only: [:index]
end
