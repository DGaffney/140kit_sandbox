WWW140kit::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  resources :analytical_offerings, path: '/analytics', only: [:index, :edit, :new, :create] do
    member do
      put 'details' => :update, as: :update
      get 'details' => :show, as: ''
      get ':curation_id/add' => :add, as: :add
      post ':curation_id/validate' => :validate, as: :validate
      get ':curation_id/verify' => :verify, as: :verify
    end
  end

  scope '/analytics/:id' do
    get '' => 'analysis_metadata#show', as: :analysis_metadata
    get ':graph_id/graph' => 'analysis_metadata#graph', as: :analysis_metadata_graph
    # get '/analytics/:id/destroy' => 'analysis_metadata#show', as: :destroy_analysis_metadata
    # should be:
    delete '' => 'analysis_metadata#destroy'
  end

  resources :instances, only: [] do
    member do
      get 'kill' => :kill_instance
      get ':id' => :show_instance, as: ''
    end
    get '' => :index_instance, as: '', on: :collection
  end

  resources :instances, as: :machines, path: '/machines', only: [] do
    get '' => :index_machine, as: '', on: :collection
    member do
      get 'edit' => :edit
      get 'kill' => :kill_machine
      get '' => :show_machine, as: ''
      # this should really be a 'put' without '/update'
      post 'update' => :update
    end
  end

  get '/datasets/new/location' => 'curations#new_location', as: :new_location_dataset
  get '/datasets/new/term' => 'curations#new_term', as: :new_term_dataset
  get '/datasets/:id/alter/:stream_type' => 'curations#new', as: :alter_dataset
  resources :curations, only: [:index, :create, :new, :show, :validate, :analyze, :alter, :import, :verify, :destroy], path: '/datasets', as: :datasets do
    member do
      get 'verify'
      get 'analyze'
      get 'import'
      get 'archive'
      # this _should_ be a member route, right?
      # post 'validate'
    end
    get 'search', on: :collection
  end
  post '/datasets/validate' => 'curations#validate', as: :dataset_validate
  get '/:user_name/datasets' => 'curations#researcher', as: :researcher_datasets
  get '/analysis/:curation_id/:analysis_metadata_id' => 'analysis_metadata#results', as: :curation_analysis

  get '/admin/panel' => 'admin#panel', as: :admin_panel

  # super annoying that you can't specify a key other than :id in resources
  # resources :researchers, key: :user_name, only: [:index, :show, :update, :edit, :destroy] do
  #   member do
  #     get 'dashboard'
  #   end
  # end
  resources :researchers, only: [:index]
  scope '/researchers/:user_name' do
    get '' => 'researchers#show', as: :researcher
    get 'edit' => 'researchers#edit', as: :edit_researcher
    get 'new' => 'researchers#new', as: :new_researcher
    put '' => 'researchers#update'
    delete '' => 'researchers#destroy'
  end

  get 'dashboard' => 'researchers#dashboard', as: :dashboard

  resources :posts, except: [:show]

  get '/posts/:id/:slug' => 'posts#show', as: :post
  get '/about' => 'posts#about', as: :about

  match '/auth/:provider/callback' => 'sessions#create'
  match '/signout' => 'sessions#destroy', as: :signout
  match '/auth/failure' => 'sessions#fail'

  root to: 'home#index'
  resources :analytical_offering_variable_descriptors, path: '/variables'
  get '/dependencies/:id/new' => 'analytical_offering_requirements#new', as: :new_dependency
  resources :analytical_offering_requirements, path: '/dependencies'
  get '/variables/:id/new' => 'analytical_offering_variable_descriptors#new', as: :new_variable

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
