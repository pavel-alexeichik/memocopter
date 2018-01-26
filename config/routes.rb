Rails.application.routes.draw do
  authenticated :user do #-> if user is logged in
    root 'home#dashboard', as: :dashboard
    resources :cards, only: [:index, :create, :update, :destroy]
    get 'training', to: 'training#index', as: :training
    ActiveAdmin.routes(self)
  end

  devise_for :users, skip: [:registrations], controllers: {
    sessions: 'sessions'
  }
  devise_scope :user do
    post 'signup', to: 'registrations#create', as: :user_registration
    post 'try_as_guest', to: 'registrations#try_as_guest', as: :try_as_guest
  end

  unauthenticated :user do #-> if user is not logged in
    root 'home#landing', as: :unauthenticated
    get '*anypath', to: redirect('/')
  end
end
