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

  def standard_roles aResourceSymbol
    r = (aResourceSymbol.to_s + "_read").to_sym
    role r do
      #has_permission_on aResourceSymbol, :to => :read
      has_permission_on aResourceSymbol, :to => [:index, :show]
      #has_permission_on :CalmSessions, :to => [:new, :create, :destroy]
    end
    r = (aResourceSymbol.to_s + "_write").to_sym
    role r do
      has_permission_on aResourceSymbol, :to => [:edit, :update]
      #has_permission_on :CalmSessions, :to => [:new, :create, :destroy]
    end
    r = (aResourceSymbol.to_s + "_create").to_sym
    role r do
      has_permission_on aResourceSymbol, :to => [:new, :create]
      #has_permission_on :CalmSessions, :to => [:new, :create, :destroy]
    end
    r = (aResourceSymbol.to_s + "_destroy").to_sym
    role r do
      has_permission_on aResourceSymbol, :to => [:destroy]
      #has_permission_on :CalmSessions, :to => [:new, :create, :destroy]
    end
  end

#privileges do
#  privilege :read do
#    includes :index, :show
#  end
#end
# might do same for :write, :add, :remove

  # users who have no permission are guest see user.rb >> role_symbols
  role :guest do
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
  
  role  :calmapp_versions_alterwithredisdb do
    has_permission_on [:calmapp_versions], :to => [:version_alterwithredisdb]
  end
  role :calmapp_versions_publish do
    has_permission_on [:redis_databases], :to => [:publish]
  end
  
  role :users_invite do
    has_permission_on [:users], :to => [:invite_user]
  end
  
  role :translations_translate do
    has_permission_on [:translations], :to => [:update, :index] #do
      #if_attribute "calmapp_versions_translation_language.translation_language"=> is {current_user.translation}
      #if_attribute :cavs_translation_language_id => is_in {user.calmapp_versions_translation_languages.collect { |cavtl| cavtl.id}}
   # end
  end
  
  standard_roles :calmapp_versions_translation_languages
  standard_roles :calmapp_versions
  standard_roles :calmapps
  standard_roles :dot_key_code_translation_editors 
  standard_roles :languages
  standard_roles :profiles
  standard_roles :redis_databases
  standard_roles :redis_instances
  standard_roles :release_statuses
  standard_roles :special_partial_dot_keys
  standard_roles :translations
  standard_roles :translation_hints
  standard_roles :translation_languages
  standard_roles :translations_uploads
  standard_roles :users
  standard_roles :whiteboard_types
  standard_roles :whiteboards

  

end
