Rails.application.routes.draw do
  root to: 'dashboard#index'
  resources :cards_sets
  resources :cards
end
