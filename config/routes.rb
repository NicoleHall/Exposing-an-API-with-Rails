Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :presents, only: [:index, :show]
      resources :users, only: [:index, :show]
    end
  end
end
