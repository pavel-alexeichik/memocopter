Rails.application.routes.draw do
  devise_for :users
  root to: 'dashboard#index'
  resources :cards_sets
  resources :cards
end
