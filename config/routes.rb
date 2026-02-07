# config/routes.rb
Rails.application.routes.draw do
  root "events#index"

  resources :events, only: [:index, :show, :new, :create] do
    collection do
      get :merci
    end
  end

  # Page découverte des danses
  get '/decouvrir', to: 'pages#discover', as: :discover

  # Admin (optionnel pour plus tard)
  namespace :admin do
    resources :events
  end
end
