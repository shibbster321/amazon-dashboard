Rails.application.routes.draw do

  devise_for :users
  root to: 'pages#home'
  get '/getetsy/', to: 'pages#etsycall', as: 'etsypath'
  get '/etsyauthorize/', to: 'pages#etsyauthorize', as: 'etsyauthorize'
  get '/amzn/', to: 'pages#amzn', as: 'amzn'
  get '/amzn_inv/', to: 'pages#amzn_inv', as: 'amzn_inv'
  get '/apis/', to: 'pages#api', as: 'api'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :permissions, only: [:index, :edit, :update, :destroy]

  get '/edit_data/', to: 'sales#edit_data', as: 'edit_data'
  delete '/destroy_data/', to: 'sales#destroy_data', as: 'destroy_data'
  resources :product_types do
    get '/inventories/', to: 'inventories#subindex', as: 'inventories'
    get '/sales/', to: 'sales#subindex', as: 'sales'
    resources :products do
    end
  end

  resources :inventories, only: [:index]
  resources :sales, only: [:index]
end
