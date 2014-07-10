Rails.application.routes.draw do
  root to: 'main#index'
  resources :quotes, :only => :index
  resources :preferences, :only => [:index, :create]
end
