Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API documentation
  mount Rswag::Ui::Engine => "/api/docs"
  mount Rswag::Api::Engine => "/api/docs"

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post "/auth/login", to: "authentication#login"

      # Users
      resources :users, only: [ :create ]
      get "/users/me", to: "users#me"

      # Spaces
      resources :spaces
      get "/spaces/categories", to: "spaces#categories"

      # Bookings
      resources :bookings do
        member do
          post :confirm
          post :cancel
        end
      end

      # Notifications
      resources :notifications, only: [ :index, :show ] do
        member do
          patch :read, to: "notifications#mark_as_read"
        end
        collection do
          get :unread
          patch :read_all, to: "notifications#mark_all_as_read"
        end
      end

      # Admin routes
      namespace :admin do
        resources :bookings, only: [ :index ]
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
