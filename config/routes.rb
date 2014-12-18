Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  get '/ns/*id', :to => "controlled_vocabularies#show", :as => "controlled_vocabulary"

  resources :vocabularies, :only => :new

end
