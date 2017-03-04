Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }

  # as :user do
  #   get '/users', :to => 'users#edit', :as => :user_root
  # end

 #  new_user_session GET    /users/sign_in(.:format)             devise/sessions#new
 #             user_session POST   /users/sign_in(.:format)             devise/sessions#create
 #     destroy_user_session DELETE /users/sign_out(.:format)            devise/sessions#destroy
 #            user_password POST   /users/password(.:format)            devise/passwords#create
 #        new_user_password GET    /users/password/new(.:format)        devise/passwords#new
 #       edit_user_password GET    /users/password/edit(.:format)       devise/passwords#edit
 #                          PATCH  /users/password(.:format)            devise/passwords#update
 #                          PUT    /users/password(.:format)            devise/passwords#update
 # cancel_user_registration GET    /users/cancel(.:format)              devise/registrations#cancel
 #        user_registration POST   /users(.:format)                     devise/registrations#create
 #    new_user_registration GET    /users/sign_up(.:format)             devise/registrations#new
 #   edit_user_registration GET    /users/edit(.:format)                devise/registrations#edit
 #                          PATCH  /users(.:format)                     devise/registrations#update
 #                          PUT    /users(.:format)                     devise/registrations#update
 #                          DELETE /users(.:format)                     devise/registrations#destroy
 #                     root GET    /                                    targets#index
 #                  targets GET    /targets(.:format)                   targets#index
 #               new_target GET    /targets/:user_id/new(.:format)      targets#new
 #              edit_target GET    /targets/:target_id/edit(.:format)   targets#edit
 #                          POST   /targets(.:format)                   targets#create
 #                          PATCH  /targets/:target_id(.:format)        targets#update
 #             send_message GET    /messages/:message_id/send(.:format) messages#send_message
 #                 messages GET    /messages(.:format)                  messages#index
 #              new_message GET    /messages/new(.:format)              messages#new
 #             edit_message GET    /messages/:message_id/edit(.:format) messages#edit
 #                          POST   /messages(.:format)                  messages#create
 #                          PATCH  /messages/:message_id(.:format)      messages#update
 #                    users GET    /users(.:format)                     users#index
 #                 new_user GET    /users/new(.:format)                 users#new
 #                edit_user GET    /users/:user_id/edit(.:format)       users#edit
 #                          POST   /users(.:format)                     users#create
 #                          PATCH  /users/:user_id(.:format)            users#update


  root 'site#splash', as: :splash
  get "targets", to: "targets#index", as: "targets"
  get "/targets/:user_id/new", to: "targets#new", as: "new_target"
  get "/targets/:target_id/edit", to:"targets#edit", as: "edit_target"
  post "/targets", to: "targets#create"
  patch "/targets/:target_id", to:"targets#update"
  delete "/targets/:target_id", to:"targets#destroy", as: "delete_target"

  get "/messages/:message_id/send", to:"messages#send_message", as: "send_message"
  get "messages", to: "messages#index", as: "messages"
  get "/messages/new", to: "messages#new", as: "new_message"
  get "/messages/:message_id/edit", to:"messages#edit", as: "edit_message"
  post "/messages", to: "messages#create"
  post "/messages/:message_id/copy", to: "messages#copy", as: "copy_message"
  patch "/messages/:message_id", to:"messages#update"
  delete "/messages/:message_id", to:"messages#destroy", as: "delete_message"


  get "/users", to: "users#index", as: "users"
  get "/users/new", to: "users#new", as: "new_user"
  get "/users/:user_id/edit", to:"users#edit", as: "edit_user"
  post "/users", to: "users#create"
  patch "/users/:user_id", to:"users#update"
  delete "/users/:user_id", to:"users#destroy", as: "delete_user"

end
