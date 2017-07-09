Translate::Application.routes.draw do

  

  
  
  scope "/:locale" do
   resources :profiles
   resources :translation_hints
   resources :translations_uploads
   resources :contacts
   resources :delayed_jobs
   # root will check permission and if ok redirect to whiteboards
   #root :to => "whiteboards#index"
   #root :to => "whiteboards#index" #"permissions#select" 
   root :to => 'help#application'
   get 'help/application', :to => 'help#application', :as => 'application_help'
   get 'help/translator', :to => 'help#translator', :as => 'translator_help'
   get 'help/translator_objects', :to => 'help#translator_objects', :as => 'translator_objects_help'
   get 'help/translation_process', :to => 'help#translation_process', :as => 'translation_process_help'
   get 'help/interpolations', :to => 'help#interpolations', :as => 'translation_interpolations_help'
   get 'help/developer', :to => 'help#developer', :as =>  'developer_help'
   get 'help/administrator', :to => 'help#administrator', :as => 'administrator_help'
   get 'help/role_of_english', :to => 'help#role_of_english', :as => 'role_of_english_help'
   get 'help/redis_databases', :to => 'help#redis_databases', :as => 'redis_databases_help' 
   get 'help/redis_instances', :to => 'help#redis_instances', :as => 'redis_instances_help'
   get 'help/getting_started', :to => 'help#getting_started', :as => 'getting_started'
   get 'help/admin_getting_started', :to => 'help#admin_getting_started', :as => 'admin_getting_started'
   get 'help/admin_users', :to => 'help#user_admin', :as => 'user_admin'
   get 'help/admin_applications_versions_languages', :to => 'help#admin_applications_versions_languages', :as => 'admin_applications_versions_languages'
   get 'help/todo', :to => 'help#todo', :as => 'todo'
   get 'help/contents', :to=> 'help#contents', :as => 'contents'
   get 'help/admin_publishing', :to=> 'help#publishing', :as => 'publishing'
   get 'help/translator_publishing', :to=> "help#translatorpublishing", :as => "translator_publishing_help"
   get 'help/administrator_publishing', :to => "help#administrator_publishing", :as => 'administrator_publishing_help'
   get 'help/admin_uploading', :to=> 'help#uploading', :as => 'uploading'
   get 'help/translator_ui', :to => 'help#translator_ui', :as => 'translator_ui'
   get 'help/developers_english', :to => 'help#developers_english', :as => 'developers_english'
   get 'help/redis_installation', :to => 'help#redis_installation', :as => 'redis_installation'
   get 'help/deep_copy', :to => 'help#deep_copy', :as => 'help_deepcopy'
   get 'help/deep_delete', :to => 'help#deep_delete', :as => 'help_deepdelete'
   get 'help/background_processes', :to => 'help#background_processes', :as => 'background_processes'
   get 'help/prerequisites', :to => 'help#prerequisites', :as => 'prerequisites'
   get 'help/workflow', :to => 'help#admin_workflow', :as => 'admin_workflow'
   
   
=begin
   scope "/auth_user/:user_id" do
      resources :permissions
      get '/permissions_select' => 'permissions#select',      :as => :permissions_select, via: :all
      get '/set_permission/:id' => 'permissions#set_current', :as => :set_permission, via: :all
   end
   
   get '/auth_user/set_permission_by_ajax' => 'permissions#set_current_by_ajax', :as => :set_permission_by_ajax, via: :all
=end   
    
   #devise_for :users #do
=begin
   devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}, 
     controllers: {confirmations: "users/confirmations", passwords: "users/passwords", registrations: "users/registrations", 
         sessions: "users/sessions", 
         unlocks: "users/unlocks", :invitations => 'users/invitations'}
=end
   devise_for :users, :controllers => { :invitations => 'invitations', sessions: "users/sessions" }
     match '/users/:id', :to => 'users#destroy', :as => :destroy_user, :via => :delete
     #get '/users_select' => 'users#select',      :as => :users_select, via: :all
     #get '/users', :to => 'users#index', :as=> :users
     get "users/:id/edit_password",   :to => "users#edit",   :as => :edit_password  
     patch "users/:id/update_password", :to => "users#update", :as => :update_password  
      # for unlocking another user
     patch "users/:id/unlock_user",     :to => "users#unlock_user", :as => :unlock_user
     get "users/new", :to => "users#new", :as => "new_user" 
     #get "/users", :to => "users#select", :as => :users
     get "users/:id/edit", :to=> "users#edit", :as => :user_edit 
     post "users/create", :to=> "users#create", :as => :user_create
     patch "users/:id/update", :to=> "users#update", :as => :user_update
     #get "users/new_invitation", :to => "users#new_invitation", :as=> :new_user_invitation
     post "users/add_invitation", :to => "users#invite_user", :as => :invite_user
     get "users/send_timezone_offset", :to => "users#timezone_offset", :as => "send_timezone_offset" 
   #end
    get "delayed_job/start", :to => "delayed_jobs#start", :as => "start_delayed_jobs_queue"
    
   resources :languages
   resources :users, :only => [:index]
   resources :whiteboard_types
   resources :whiteboards
   #resources :location_tree, :only => [:index, :show]
   #resources :locations
   #resources :areas

   resources :translation_languages

   #resources :organisations

    #resources :servers
   # to create a new child we need the parent_id
    #get '/organisations/new/:parent_id(.:format)' => 'organisations#new', :as => :new_child_organisation, via: :all
    #get '/translation_languages/new/:parent_id(.:format)' => 'translation_languages#new', :as => :new_child_translation_language, via: :all
    #get '/areas/new/:parent_id(.:format)' => 'areas#new',                 :as => :new_child_area, via: :all
    #get '/servers/new/:parent_id(.:format)' => 'servers#new',             :as => :new_child_server, via: :all
    
   resources :calmapps
   resources :calmapp_versions
   post "calmapp_versions/deep_copy"=> "calmapp_versions#deep_copy", :as=>"version_deep_copy"
   get "calmapp_versions/deep_copy_params/:id"=> "calmapp_versions#deep_copy_params", :as=>"version_deep_copy_params"
   get "calmapp_versions_translation_languages/deep_copy"=> "calmapp_versions_translation_languages#deep_copy", :as=>"version_translation_language_deep_copy"
   delete "calmapp_versions_translation_languages/deep_destroy/:id" => "calmapp_versions_translation_languages#deepdestroy", :as => "versions_language_deepdestroy"
   delete "calmapp_versions/deep_destroy/:id" => "calmapp_versions#deepdestroy", :as => "version_deepdestroy"
   
   
   resources :release_statuses
   resources :redis_databases, :only=>[:index, :destroy, :edit]
   resources :redis_instances
   #resources :calmapp_versions_redis_databases, :only=> [:index, :new, :create, :update]
   get 'unused_redis_database_indexes' => 'redis_instances#unused_redis_database_indexes', :as => 'redis_databases_getunused', via: :all
   get 'next_unused_redis_database_index'=> 'redis_instances#next_redis_database_index'  , :as => 'redis_databases_getnextindex', :via=> :all
   
   resources :calmapp_versions_translation_languages
   resources :translations #, :except=>:show#, :only=> [:new, :index]
   get "translations/dev_new" => "translations#dev_new", :as => "dev_new_translation", via: :all
   get "translations/dev_create" => "translations#dev_create", :as => "dev_create_translation", via: :all
   #match "translations_editable_list" => "translations#editable_list", :as => "translators_index"
   #match "redis_translations/edito" => "redis_translations#edito", :as => "edito_translation"
   resources :translation_parameters, :only=> [ :new, :index]
   resources :special_partial_dot_keys
   #match "translation_parameters/save" => "translation_parameters#save", :as => "save_translation_params"
   
   #get "translations_uploads/file_to_redis/:id" => "translations_uploads#file_to_redis", :as => "to_redis"#, via: :all
   #get "translations_uploads/select_translation_to_redis/:id" => "translations_uploads#select_translation_to_redis", :as => "select_to_redis"# via: :all

   #get "translations_uploads/write_yaml_file_to_db/:id" => "calmapp_versions_translation_languages#write_file_to_db", :as=> "write_yaml_file_to_db"#, :via => :all

   get "redis_databases/redis_to_yaml/:id" => "redis_databases#redis_to_yaml", :as => "redis_to_yaml", via: :all
   get "calmapp_version/version_alterredisdb/:id" => "calmapp_versions#redisdbalter", :as => "version_alterredisdb"#, via: :all
   #get "calmapp_versions_redis_database/version_alterwithredisdb/:calmapp_versions_redis_database_id" => "calmapp_versions_redis_databases#version_alterwithredisdb", :as => "version_alterredisdb"#, via: :all
   post "calmapp_version/version_publish/:id" => "redis_databases#versionpublish", :as =>"redis_databases_versionpublish" #, :via => :all
   post "calmapp_versions_translation_language/publish/:id" => "calmapp_versions_translation_languages#languagepublish", :as =>"calmapp_versions_translation_languages_languagepublish", :defaults => { :format => 'js' }
   post "calmapp_versions_translation_language/translatorproductionpublish/:id" => "calmapp_versions_translation_languages#translatorproductionpublish", :as =>"calmapp_versions_translation_languages_translatorproductionpublish", :defaults => { :format => 'js' }
   # This route publishes a version
   get "calmapp_versions_translation_language/translatorpublish/:id" => "calmapp_versions_translation_languages#translatorpublish", :as => "translator_publish", :defaults => { :format => 'js' }
   # This route shows the user what and where they can publish
   get "users/:id/request_translators_dbs", :to=> "users#translatorpublishing", :as => "translator_publishing"
   
   resources :translation_editor_params
   resources :special_partial_dot_keys
   resources :dot_key_code_translation_editors, :only=> [:index, :edit, :show] 
   #get "calmapps/all_in_one_new/" => "calmapps#all_in_one_new", :as => "all_in_one_new"
   #get "calmapps/all_in_one_create" => "calmapps#all_in_one_create"
   

   #get '/contact', :to => 'static_pages#contact'
   get '/about',   :to => 'static_pages#about'
   #get '/help',    :to => 'static_pages#help' 
  end
  # The priority is based upon order of creation:
  # first created -> highest priority.

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
