Rails.application.routes.draw do
  root 'mazes#index'

  resources :mazes do
    member do
      get :solve
    end
  end

end
