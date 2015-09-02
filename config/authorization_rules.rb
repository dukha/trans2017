# to load an altered or alternate rules file use:
#   Authorization::Engine.instance(path_to_file)

=begin
 It allows me to use this code in my Role class:

def reload_authorization_rules
    Authorization::Engine.force_reload
end

And now I can have my roles and permissions stored in the database and updated after_save roles. 
=end
authorization do

  # list all roles which are defiend here by:
  # Authorization::Engine.instance.roles

  def standard_roles aResourceSymbol, options = {}
    roles_read = [:index, :show]
    roles_write = [:edit, :update]
    roles_create = [:new, :create]
    roles_destroy = [:destroy]
    exclude = options[:exclude]
    if ! exclude.is_a? Array
      exclude = [exclude] 
    end
    if ! exclude.nil?
      if ! exclude.empty?
        roles_read = roles_read - exclude
        roles_write = roles_write - exclude
        roles_create = roles_create - exclude
        roles_destroy = roles_destroy - exclude
      end
    end
    if !roles_read.empty?
      r = (aResourceSymbol.to_s + "_read").to_sym
      role r do
        has_permission_on aResourceSymbol, :to => roles_read
      end
    end
    if !roles_write.empty?
      r = (aResourceSymbol.to_s + "_write").to_sym
      role r do
        has_permission_on aResourceSymbol, :to => roles_write
      end
    end
    if !roles_create.empty?
      r = (aResourceSymbol.to_s + "_create").to_sym
      role r do
        has_permission_on aResourceSymbol, :to => roles_create
      end
    end
    if !roles_destroy.empty?
      r = (aResourceSymbol.to_s + "_destroy").to_sym
      role r do
        has_permission_on aResourceSymbol, :to => roles_destroy
      end
    end
 end #def 
  

#privileges do
#  privilege :read do
#    includes :index, :show
#  end
#end
# might do same for :write, :add, :remove

  # users who have no permission are guest see user.rb >> role_symbols
  role :guest_visit do
    has_permission_on :languages, :to => [:change_application_language, :index, :show]
    has_permission_on :whiteboards, :to => [:read]
    #has_permission_on :CalmSessions, :to => [:new, :create, :destroy]
  end
=begin
  role :location_tree do
    has_permission_on [:location_tree], :to => [:index, :show]
    #has_permission_on :CalmSessions, :to => [:new, :create, :destroy]
  end
=end
  standard_roles :users
  standard_roles :profiles
  standard_roles :contacts
  standard_roles :delayed_jobs, {:exclude => :create}
  
  role :rules_read do
    has_permission_on :authorization_rules, :to => [:read]
  end
=begin  
  role :delayed_jobs_read  do
    has_permission_on [:delayed_jobs], :to => [:index, :show]
  end
  
  role :delayed_jobs_write  do
    has_permission_on [:delayed_jobs], :to => [:edit, :update]
  end
  
  role :delayed_jobs_destroy  do
    has_permission_on [:delayed_jobs], :to => [:destoy]
  end
  
  role :delayed_jobs_start  do
    has_permission_on [:delayed_jobs], :to => [:start]
  end
=end  
  role :users_read do
    has_permission_on [:users], :to => [:index]
  end
  role :users_write do
    has_permission_on [:users], :to => [:unlock_user]
  end
  role :redis_databases_getunused do
    has_permission_on [:redis_instances],  :to=>[:unused_redis_database_indexes]
  end
  role :redis_databases_getnextindex do
    has_permission_on [:redis_instances],  :to=>[:next_redis_database_index]
  end
  
  role  :calmapp_versions_redisdbalter do
    has_permission_on [:calmapp_versions], :to => [:redisdbalter]
  end
  role :calmapp_versions_translation_languages_deepdestroy do
    has_permission_on [:calmapp_versions_translation_language], :to=> [:deep_destroy]
  end
  role :calmapp_versions_deepdestroy do
    has_permission_on [:calmapp_versions], :to=> [:deep_destroy]
  end
  role :calmapp_versions_deepcopy do
    has_permission_on [:calmapp_versions], :to=> [:deep_copy]
  end
  role :calmapp_versions_deepcopyparams do
    has_permission_on [:calmapp_versions], :to=> [:deep_copy_params]
  end
  role :redis_databases_versionpublish do
    has_permission_on [:redis_databases], :to => [:versionpublish]
  end
  role :calmapp_versions_translation_languages_languagepublish do
    has_permission_on [:calmapp_versions_translation_languages], :to => [:languagepublish]
  end
  
  role :users_invite do
    has_permission_on [:users], :to => [:invite_user]
    has_permission_on [:invitations], :to => [ :create, :new, :update, :edit]
  end   
  
 role :translations_develop do
   has_permission_on [:translations], :to => [:index, :update, :index, :destroy, :new, :edit, :create] do
     if_attribute :"calamapp_version_translation_language.calmapp_version.calmapp" =>  intersects_with {user.developer_calmapps}
   end 
 end  
  
  role :translations_translate do
    has_permission_on [:translations], :to => [:update, :index] #do
      #if_attribute "calmapp_versions_translation_language.translation_language"=> is {current_user.translation}
      #if_attribute :cavs_translation_language_id => is_in {user.calmapp_versions_translation_languages.collect { |cavtl| cavtl.id}}
   # end
  end
  
  standard_roles :calmapp_versions_translation_languages
  #standard_roles :calmapp_versions_redis_databases
  standard_roles :calmapp_versions
  standard_roles :calmapps
  standard_roles :dot_key_code_translation_editors 
  standard_roles :languages
  standard_roles :profiles
  standard_roles :redis_databases
  standard_roles :redis_instances
  standard_roles :release_statuses
  standard_roles :special_partial_dot_keys, {:exclude => [:create, :write, :destroy]}
  standard_roles :translations
  standard_roles :translation_hints
  standard_roles :translation_languages
  standard_roles :translations_uploads
  standard_roles :users
  standard_roles :whiteboard_types
  standard_roles :whiteboards

  

end
