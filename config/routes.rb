Rails.application.routes.draw do
  authenticated :user do #-> if user is logged in
    root 'home#dashboard', as: :dashboard
    resources :cards_sets
    resources :cards
  end

  unauthenticated :user do #-> if user is not logged in
    root 'home#landing', as: :unauthenticated
  end

  devise_for :users, :skip => [:registrations]
  devise_scope :user do
    post 'signup', to: 'devise/registrations#create', as: :user_registration
  end

end
