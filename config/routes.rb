Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/users',  controller: :users, action: :create
  delete '/user', controller: :users, action: :destroy
  get '/user',    controller: :users, action: :show
  resources :tokens, only: [:create]
end
