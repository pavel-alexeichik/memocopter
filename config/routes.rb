Rails.application.routes.draw do
  authenticated :user do #-> if user is logged in
    root 'home#dashboard', as: :dashboard
    resources :cards, only: [:index, :create, :update, :destroy]
  end

  unauthenticated :user do #-> if user is not logged in
    root 'home#landing', as: :unauthenticated
  end

  devise_for :users, skip: [:registrations], controllers: {
    sessions: 'sessions'
  }
  devise_scope :user do
    post 'signup', to: 'devise/registrations#create', as: :user_registration
  end

end
