class Profile < ActiveRecord::Base
  #attr_readonly :name
  has_many :user_profiles
  has_many :users, :through => :user_profiles 
  validates :name, :presence => true, :uniqueness=>true
  
  #validate :only_non_protected_profiles, :on => :update
  # roles are defineds as symbols in config/authorization_rules.rb
  # list all roles which are defiend there:  Authorization::Engine.instance.roles
  # roles do not change in any way at run-time so there is no need to keep them in the DB
  # Also such redundancy would be complicated.
  # A permission object uses the ORM to persist the set of roles the user with this permission can assume.
  # (If we switch to profiles we will have instead belongs_to :user_profile  and serialise the set there)
  # Here serialize tells ActiveRecord to serialize (to yaml) whatever object(-graph) roles points to.
  # For the DB this needs a migration with: add_column :permissions, :roles, :text
  # http://www.postgresql.org/docs/8.3/interactive/datatype-character.html says: text has variable unlimited length
  # It is unlikely the yaml will be too long and be truncated.
  # see also methods roles and add_role
  serialize :rools, Array

  # return the roles for this profile. If not yet initialized then initialize with empty
  # set and return it.
  # this also shows how to implement setter and getter in ruby
  def roles(selectedRoles=nil)
    if selectedRoles.nil?
      read_attribute(:rools) || write_attribute(:rools, [])
    else
      # all should be symbols
      sel_roles = selectedRoles.collect {|each| each.to_sym} 
      #remove duplicates
      sel_roles = sel_roles.to_set.to_a
      write_attribute(:rools, sel_roles)
    end
  end
  alias_method :roles=, :roles   #setter and getter

  # if the aSymbol is not a defined role then do nothing
  # other wise add it.
  def add_role aSymbol
    if Profile.available_roles.include? aSymbol.to_sym
      roles.add aSymbol.to_sym
      return true
    end
    false
  end

  def display
    answer = ''
    roles.each do |role|
      answer += ','
      answer += role.to_s
    end
    answer[1..-1]  #cut out leading comma
  end

  def to_s
    display
  end
=begin  
  def only_non_protected_profiles
    if protecteded_profile
      
    end
  end
=end
 
  # seed makes sure the profiles named sysadmin or guest remain reserved
  def self.seed

    reserved_profile = 'recovery_profile'
    roles = [:profiles_read, :profiles_write , :profiles_create, 
      #:permissions_read, :permissions_write , :permissions_create,
      :users_read, :users_write , :users_create
    ]
    Profile.create :name => reserved_profile, :roles => roles, :protected_profile => true unless self.recovery_profile

    reserved_profile = $SYSADMIN
    Profile.create :name => reserved_profile, :roles => Profile.available_roles, :protected_profile => true  unless self.sysadmin
    reserved_profile = 'guest'
    Profile.create :name => reserved_profile, :roles => [:guest_visit, :whiteboards_read], :protected_profile => true unless self.guest
    
    roles= [:translations_read, :translations_write, :contacts_create, :calmapp_versions_translation_languages_read, 
      :calmapp_versions_translation_languages_languagepublish, :redis_databases_read, :redis_instances_read,
      :release_statuses_read, :translation_languages_read]
    Profile.create(:name=>'translator', :roles => roles, :protected_profile => true) 
    
    roles= [:translations_read, :translations_write, :translations_destroy, :contacts_create, :contacts_read, 
      :contacts_write, :contacts_destroy, :translation_hints_read, :transaltion_hints_write, :translation_hints_destroy, 
      :translation_hints_create, :calmapp_versions_translation_languages_languagepublish, :redis_databases_read, :redis_instances_read,
      :release_statuses_read, :translation_languages_read, :calmapp_versions_versionpublish]
    Profile.create(:name=>'developer', :roles => roles, :protected_profile => true)
    
  roles= [  :users_read,
   :users_write,
   :users_create,
   :users_destroy,
   :profiles_read,
   :redis_databases_getunused,
   :redis_databases_getnextindex,
   :calmapp_versions_redisdbalter,
   :calmapp_versions_translation_languages_deepdestroy,
   :calmapp_versions_deepdestroy,
   :calmapp_versions_deepcopy,
   :calmapp_versions_deepcopyparams,
   :calmapp_versions_publish,
   :calmapp_versions_translation_languages_read,
   :calmapp_versions_translation_languages_write,
   :calmapp_versions_translation_languages_create,
   :calmapp_versions_translation_languages_destroy,
   :calmapp_versions_read,
   :calmapp_versions_write,
   :calmapp_versions_create,
   :calmapp_versions_destroy,
   :calmapps_read,
   :calmapps_write,
   :calmapps_create,
   :calmapps_destroy,
   :redis_databases_read,
   :redis_databases_write,
   :redis_databases_create,
   :redis_databases_destroy,
   :redis_instances_read,
   :translations_read,
   :translations_write,
   :translations_create,:translation_languages_read,
 :translation_languages_write,
 :translation_languages_create,
 :translation_languages_destroy,
 :translations_uploads_read,
 :translations_uploads_write,
 :translations_uploads_create,
 :translations_uploads_destroy,
 :contacts_create, :contacts_destroy, :contacts_write, :contacts_destroy]
   Profile.create(:name=>'application_administrator', :roles => roles, :protected_profile => true)
  end

  def self.demo
     
    end
  # all roles defined in config/authorization_rules.rb
  # as a collection of symbols
  def self.available_roles
    Authorization::Engine.instance.roles
    
  end

  # profile to use for root user
  def self.sysadmin
    Profile.find_by(name: $SYSADMIN)
  end

  # profile to use for guest user
  def self.guest
    Profile.find_by(name: "guest")
  end
  
  def self.recovery_profile
    Profile.find_by(name: 'recovery_profile')
  end
  
end

=begin
   reads= []
    creates =[]
    writes =[]
    destroys=[]
    misc =[]
    
    available_roles.each do |role|
      role=role.to_s
      if role.index("_read") then
        reads<<role
      elsif role.index("_create")  then
        creates<<role
      elsif role.index("_write") then
        writes<<role
      elsif role.index("_destroy") then
        destroys<<role
      else
        misc<<role
      end        
     end
    puts reads
    puts creates
    puts writes
    puts destroys
    puts misc
    puts 
=end

# == Schema Information
#
# Table name: profiles
#
#  id         :integer         not null, primary key
#  roles      :text
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)     not null
#

#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: profiles
#
# * id         :integer         not null
#   roles      :text
#   created_at :datetime        not null
#   updated_at :datetime        not null
#   name       :string(255)     not null
#
#  Indexes:
#   index_profiles_on_name  name  unique
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
