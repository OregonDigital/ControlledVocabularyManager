Rails.application.routes.draw do
  #devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  get "/admin", :to => "admin#index", :as => "admin"

  namespace :admin do
    resources :users
  end

  Rails.application.routes.draw do
    devise_for :users, controllers: {
      registrations: 'users/registrations'
    }
  end

  patch 'terms/*id/deprecate_only', :to => "terms#deprecate_only", :as => "deprecate_only_term"
  patch 'terms/*id', :to => "terms#update", :as => "update_term"
  get 'terms/*id/edit', :to => "terms#edit", :as => "edit_term"
  get 'terms/*id/deprecate', :to => "terms#deprecate", :as => "deprecate_term"
  post 'terms/*id/review_update', :to => "terms#review_update", :as => "review_update_term"
  get "/terms/*id/mark", :to => "terms#mark_reviewed", :as => "mark_term"

  resources :vocabularies, :only => [:index, :new, :create, :edit]
  patch 'vocabularies/*id/deprecate_only', :to => "vocabularies#deprecate_only", :as => "deprecate_only_vocabulary"
  patch 'vocabularies/*id', :to => "vocabularies#update", :as => "update_vocabulary"
  get '/vocabularies/*vocabulary_id/new', :to => "terms#new", :as => "new_term"
  post 'vocabularies/*id/review_update', :to => "vocabularies#review_update", :as => "review_update_vocabulary"
  post '/vocabularies/*vocabulary_id', :to => "terms#create", :as => "create_term"
  get 'vocabularies/*id/deprecate', :to => "vocabularies#deprecate", :as => "deprecate_vocabulary"
  get "/vocabularies/*id/mark", :to => "vocabularies#mark_reviewed", :as => "mark_vocabulary"

  resources :predicates, :only => [:index, :new, :create, :edit]
  patch 'predicates/*id/deprecate_only', :to => "predicates#deprecate_only", :as => "deprecate_only_predicate"
  post 'predicates/*id/review_update', :to => "predicates#review_update", :as => "review_update_predicate"
  patch 'predicates/*id', :to => "predicates#update", :as => "update_predicate"
  get 'predicates/*id/deprecate', :to => "predicates#deprecate", :as => "deprecate_predicate"
  get "/predicates/*id/mark", :to =>"predicates#mark_reviewed", :as => "mark_predicate"

  resources :relationships, :only => [:index, :create, :edit]
  patch 'relationships/*id/deprecate_only', :to => "relationships#deprecate_only", :as => "deprecate_only_relationship"
  post 'relationships/*id/review_update', :to => "relationships#review_update", :as => "review_update_relationship"
  patch 'relationships/*id', :to => "relationships#update", :as => "update_relationship"
  get 'relationships/*id/deprecate', :to => "relationships#deprecate", :as => "deprecate_relationship"
  get "/relationships/*id/mark", :to =>"relationships#mark_reviewed", :as => "mark_relationship"
  get "/relationships/*term_id/new", :to =>"relationships#new", :as => "new_relationship"

  get "/relationships/*term_id/choose", :to =>"relationships#relationship_type", :as => "relationship_type"

  get '/ns/*id', :to => "terms#show", :as => "term"

  #These features are not yet tested with the new Git integration stuff
  #TODO: Test the importing and its ability to synchronize with the triple
  #store and with the git repo for the triples.
  #
  get "/import_rdf", :to => "import_rdf#index", :as => "import_rdf_form"
  post "/import_rdf", :to => "import_rdf#import", :as => "import_rdf"

  get "/load_rdf", :to => "import_rdf#load", :as => "load_rdf_form"
  post "/load_rdf", :to => "import_rdf#save", :as => "save_rdf"

  get "/review", :to => "review#index", :as => "review_queue"
  get "/review/*id/edit", :to => "review#edit", :as => "review_edit"
  get "/review/*id", :to => "review#show", :as => "review_term"

  get "/nav", :to => "home#nav", :as => "nav"
  get "/can_edit", :to => "home#can_edit", :as => "can_edit"
 end
