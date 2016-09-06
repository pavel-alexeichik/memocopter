Rails.application.routes.draw do
  authenticated :user do #-> if user is logged in
    root 'home#dashboard', as: :dashboard
    resources :cards_sets
    resources :cards
  end

  unauthenticated :user do #-> if user is not logged in
    root 'home#landing', as: :unauthenticated
  end

  # devise_for :users
  # devise_for :users, :skip => [:sessions]
  devise_scope :user do
    post 'signup' => 'devise/registrations#create', :as => :user_registration
    get 'signin' => 'devise/sessions#new', :as => :new_user_session
    post 'signin' => 'devise/sessions#create', :as => :user_session
    # delete "/logout" => "devise/sessions#destroy"
    get 'users/confirmation/new' => 'devise/confirmations#new', :as => 'new_user_confirmation'
    get 'users/unlock/new' => 'devise/unlocks#show', :as => 'new_user_unlock'
  end

end
