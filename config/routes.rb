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

  root 'site#splash', as: :splash
  get "/pages/:page", to: "pages#show", as: :pages
  get "targets", to: "targets#index", as: "targets", path: "friends"
  get "/targets/report", to:"targets#report", as: "report_target"
  get "/friends/new", to: "targets#new", as: "new_target"
  get "/friends/:target_id/edit", to:"targets#edit", as: "edit_target"
  get "/friends/:target_id/step_one", to:"targets#update" #only used if someone hits the back button on step 3
  patch "/friends/:target_id/step_one", to:"targets#update", as: "step_one_edit_target"
  get "/friends/:target_id/step_two", to:"targets#step_two_edit", as: "step_two_edit_target"
  get "/friends/:target_id/step_three", to:"targets#step_three_edit", as: "step_three_edit_target"
  get "/friends/:target_id/finish", to:"targets#step_three", as: "step_three_target"

  get "/targets/:target_id/unsubscribe", to:"targets#unsubscribe", as: "unsubscribe_target"
  get "/targets/:target_id/inactivate", to:"targets#inactivate", as: "inactivate_target"
  post "/friends", to: "targets#create"
  patch "/friends/:target_id", to:"targets#update"
  patch "/friends/:target_id/step_two", to:"targets#step_two_update"
  patch "/friends/:target_id/step_three", to:"targets#step_three_update"
  delete "/targets/:target_id", to:"targets#destroy", as: "delete_target"

  get "/messages/:message_id/hot", to:"messages#make_current_message", as: "current_message"
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

  get "/reps", to: "reps#index", as: "reps"
  get "/reps/new", to: "reps#new", as: "new_rep"
  get "/reps/:rep_id/edit", to:"reps#edit", as: "edit_rep"
  post "/reps", to: "reps#create"
  patch "/reps/:rep_id", to:"reps#update"
  delete "/reps/:rep_id", to:"reps#destroy", as: "delete_rep"

  get "/reps/check", to: "reps#check_congress", as: "reps_check"
  get "/reps/lookup", to: "reps#lookup_all_reps", as: "rep_lookup"

  get "/orgs", to: "orgs#index", as: "orgs"
  get "/orgs/:org_id/edit", to:"orgs#edit", as: "edit_org"
  patch "/orgs/:org_id", to:"orgs#update"

  #-------------catch all--------------------------------------------------------------#
  get "*any", to: redirect('/404'), via: :all

end
