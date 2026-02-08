Rails.application.routes.draw do
  resources :master_leases
  resources :buildings
  resources :rooms
  resources :owners

  root "buildings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
