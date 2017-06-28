Rails.application.routes.draw do
  post '/users',  controller: :users, action: :create
  delete '/user', controller: :users, action: :destroy
  get '/user',    controller: :users, action: :show
  patch '/user',  controller: :users, action: :update

  get '/user/bird_list', controller: :bird_lists, action: :show

  resources :birds, only: [:create]
  resources :tokens, only: [:create]
  resources :sightings, only: [:create, :destroy]
  resources :password_resets, only: [:create, :update]
end
