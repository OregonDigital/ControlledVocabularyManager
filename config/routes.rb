Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  get '/ns/*id', :to => "terms#show", :as => "term"

  resources :vocabularies, :only => [:index, :new, :create]
  get '/vocabularies/*vocabulary_id/new', :to => "terms#new", :as => "new_term"
  resources :terms, :only => [:create, :edit, :update]

end
