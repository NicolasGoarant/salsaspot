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

  # Pages légales
  get 'mentions-legales', to: 'pages#mentions_legales', as: 'mentions'
  get 'politique-de-confidentialite', to: 'pages#politique', as: 'politique'
  get 'cgu', to: 'pages#cgu', as: 'cgu'
  get 'contact', to: 'pages#contact', as: 'contact'
  get 'about', to: 'pages#about', as: 'about'

  # Admin (optionnel pour plus tard)
  namespace :admin do
    resources :events
  end
end
