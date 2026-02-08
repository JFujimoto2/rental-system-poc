Rails.application.routes.draw do
  resources :owner_payments
  resources :tenant_payments
  resources :contracts
  resources :tenants
  resources :master_leases
  resources :buildings
  resources :rooms
  resources :owners

  resources :imports, only: [ :new, :create ] do
    collection do
      post :preview
    end
  end

  root "buildings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
