# config/routes.rb
Rails.application.routes.draw do
  root "events#index"

  resources :events, only: [:index, :show, :new, :create] do
    collection do
      get :merci
    end
  end

  # Admin (optionnel pour plus tard)
  namespace :admin do
    resources :events
  end
end
