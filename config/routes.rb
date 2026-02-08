Rails.application.routes.draw do
  resources :owner_payments
  resources :tenant_payments
  resources :contracts
  resources :tenants
  resources :master_leases
  resources :buildings
  resources :rooms
  resources :owners
  resources :users, only: [ :index, :edit, :update ]

  resources :delinquencies, only: [ :index ]

  resources :imports, only: [ :new, :create ] do
    collection do
      post :preview
    end
  end

  # Authentication
  get "login", to: "sessions#new"
  delete "logout", to: "sessions#destroy"
  get "auth/:provider/callback", to: "sessions#create"
  get "auth/failure", to: "sessions#failure"
  post "dev_login", to: "sessions#dev_login", as: :login_as if Rails.env.local?

  root "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
