Rails.application.routes.draw do
  resources :buildings
  resources :rooms

  root "buildings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
