Rails.application.routes.draw do
  post '/users',  controller: :users, action: :create
  delete '/user', controller: :users, action: :destroy
  get '/user',    controller: :users, action: :show
  patch '/user',  controller: :users, action: :update
  put '/user',    controller: :users, action: :update

  resources :birds, only: [:create]
  resources :tokens, only: [:create]
  resources :password_resets, only: [:create, :update]
  resources :sightings, only: [:create, :destroy]
end
