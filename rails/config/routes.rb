WWW140kit::Application.routes.draw do

  # resources :analytical_offering_variables
  # 
  # resources :analytical_offering_variable_descriptors
  # 
  # resources :analytical_offerings
  # 
  # resources :analysis_metadatas


  # The priority is based upon order of creation:
  # first created -> highest priority.
  #we should just do single show pages for all these results. Make it atomic, not overwhelming like old site?
  get '/analysis/:curation_id/:analysis_metadata_id' => 'analysis_metadata#results', as: :curation_analysis 
  get '/new/dataset' => 'curations#new', as: :new_dataset
  get '/researchers/:user_name' => 'researchers#show', as: :researcher
  get '/datasets/:user_name' => 'datasets#researcher', as: :researcher_datasets
  get '/researchers/:user_name/edit' => 'researchers#edit', as: :edit_researcher
  put'/researchers/:user_name' => 'researchers#update'
  get '/posts/:id/:slug' => 'posts#show', as: :post
  get '/about' => 'posts#about', as: :about
  post '/datasets/create' => 'curations#create', as: :create_dataset
  delete '/researchers/:user_name' => 'researchers#destroy'
  resources :researchers, only: [:index]
  resources :curations, only: [:index, :new], path: '/datasets', as: :datasets
  resources :posts
  resources :datasets
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signout' => 'sessions#destroy', as: :signout
  match '/auth/failure' => 'sessions#fail'
  root to: 'home#index'
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
