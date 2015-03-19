class User < ActiveRecord::Base
#  # Include default devise modules. Others available are:
#  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
#  devise :invitable, :database_authenticatable, :registerable,
#         :recoverable, :rememberable, :trackable, :validatable
   #attr_accessor :profile_ids
  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, omniauthable:, Confirmable, :rememberable, :validatable, :encryptable, :recoverable
  devise  :database_authenticatable, :registerable,
         :trackable, :validatable,
         :timeoutable, :lockable, :invitable, :invite_key => {:email=>'', :actual_name=>''} #,:timeout_in => 10.minutes use value from  config/initializers/devise.rb

  # Setup accessible (or protected) attributes for your model
=begin Rails4  
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :username, :login, :actual_name
=end 
  # username is unique by DB index :unique => true
  # username is required by DB :null => false
  validates :email, :username, :uniqueness => true
  validates :email, presence: true
  validates :actual_name, :uniqueness => true
  validates :actual_name, presence: true
  validates :username, :uniqueness => true
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  # these relationships model the configured access permissions
  #has_many :permissions, :dependent => :destroy
  #has_many :organisations, :through => :permissions
  
  #The above are being replaced by those below. Keep both for now. mfl
  has_many :user_profiles
  #accepts_nested_attributes_for :user_profiles, :reject_if => :all_blank, :allow_destroy => true
  has_many :profiles, :through => :user_profiles
  
  
  #has_many :cavs_tl_translators, :foreign_key => "translator_id" #, :class_name=> "" 
  #accepts_nested_attributes_for :cavs_tl_translators, :reject_if => :all_blank, :allow_destroy => true
  #has_many :calmapp_versions_translation_languages, :through => :cavs_tl_translators
  has_many :translator_jobs, :foreign_key => "translator_id" , :class_name=> "CavsTlTranslator"
  #accepts_nested_attributes_for :translator_jobs, :reject_if => :all_blank, :allow_destroy => true
  has_many :calmapp_versions_translation_languages, :through => :translator_jobs
  
  has_many :developer_jobs, :foreign_key => "user_id" , :class_name=> "CalmappDeveloper"
  #accepts_nested_attributes_for :developer_jobs, :reject_if => :all_blank, :allow_destroy => true
  has_many :calmapps, :through => :developer_jobs, :source => :calmapp
=begin
     for declarative auth
     Returns the role symbols of the given user for declarative_auth. 
=end
  def role_symbols
    #if current_permission.nil?
    if profiles.empty? then 
      # if you have no permissions then you are a guest
      # this role is not assigned anywhere else!
      return [:guest]
    else
      #binding.pry
      # below is the code for using the permissions model
      #current_permission.profile.roles.collect {|role|role.to_sym}
      
      # now using 1 user has 1 profile model (actually many but at the moment UI only allows for 1)
      # This code here allows for more than 1 profile
      role_array = []
      profiles.collect { |p| role_array = role_array + p.roles}
      return roles = role_array.flatten.uniq.collect { |r| r.to_sym}  
    end   
  end

  def self.create_root_user
    username = "root"
    pw = "123456"

    # keep the simple pw for the system test on x59.alfaservers.com, calm.dhamma-eu.org/calm4test
    if ::Rails.env.production?
      pw = SecureRandom.base64(6)
    end
    u = User.find_by_username username
    if u
       result = User.update u.id, :password => pw,:password_confirmation => pw
       puts "result==#{result}"
       puts "Resetting password"
       puts "Your new password: '#{pw}'"
    else
     
      param = {:password => pw,:password_confirmation => pw,:username => username,:email => 'root@localhost.localdomain', :actual_name=> 'root'}
      puts "creating user"
      u = User.create! param
      puts "creating permission"
      #binding.pry
      u.profiles << Profile.sysadmin
      
      u.reload

      puts "Added user #{username} with permission "
      puts "Password: '#{pw}'"
      puts "end of create_root_user"
    end
  end
   
 # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
 # Overwrite Devise’s find_for_database_authentication method

 
 protected
   def self.find_for_database_authentication(warden_conditions)
     conditions = warden_conditions.dup
     login = conditions.delete(:login)
     where(conditions).where(["username = :value OR email = :value", { :value => login }]).first
   end
  
    def self.developers
      return where{developer == 't'}
    end
  
  
   def self.seed
     User.create_root_user
     pw = '123456'
     param = {:password => pw,:password_confirmation => pw,:username => 'sysadmin',:email => 'admin@calm.org', 
                :actual_name=> 'admin'}
     admin = User.create! param
     admin.profiles << Profile.sysadmin
   end
   
   def self.demo
    pw = '123456'
    param = {:password => pw,:password_confirmation => pw,:username => 'albert',:email => 'albert@calm.org', 
              :actual_name=> 'albert'}
    albert = User.create! param
    albert.profiles << Profile.sysadmin
    
    param = {:password => pw,:password_confirmation => pw,:username => 'a',:email => 'a@calm.org', 
              :actual_name=> 'a'}
    a = User.create! param
    a.profiles << Profile.sysadmin
    
    param[:username]='devvie'
    param[:actual_name] = 'developer'
    param[:email]= 'developer@calm.org'
    param[:developer] = true
    developer=User.create! param
    developer.profiles << Profile.where {name == "developer"}.first
    log.info("devvie created")
    
    param[:username]= 'trannie'
    param[:actual_name] = 'translator'
    param[:email]= 'translator@calm.org'
    param[:translator] = true
    translator=User.create! param
    translator.profiles << Profile.where {name == "translator"}.first
    
    cav_4_cs = CalmappVersionsTranslationLanguage.joins{calmapp_version_tl.calmapp}.joins{translation_language}.
            where {calmapp_version_tl.version == '4' }.
            where {calmapp_version_tl.calmapp.name == 'calm_registrar' }.
            where{translation_language.iso_code == 'cs'}.first
   cav_4_fr = CalmappVersionsTranslationLanguage.joins{calmapp_version_tl.calmapp}.joins{translation_language}.
            where {calmapp_version_tl.version == '4' }.
            where {calmapp_version_tl.calmapp.name == 'calm_registrar' }.
            where{translation_language.iso_code == 'fr'}.first  
            
    translator.calmapp_versions_translation_languages << cav_4_cs
    translator.calmapp_versions_translation_languages << cav_4_fr 
    translator.calmapp_versions_translation_languages << 
       CalmappVersionsTranslationLanguage.new(:translation_language_id =>TranslationLanguage.where{iso_code == 'ja'}.first.id,
      :calmapp_version_id => CalmappVersion.where {calmapp_id == Calmapp.where {name == 'calm_registrar'}.first.id}.first.id)
=begin      
  
CalmappVersionsTranslationLanguage.new(:translation_language_id =>TranslationLanguage.where{name == 'Czech'}.first.id,
      :calmapp_version_id => CalmappVersion.where {calmapp_id == Calmapp.where {name == 'calm_registrar'}.first.id}.first.id)
    translator.calmapp_versions_translation_languages << 
       CalmappVersionsTranslationLanguage.new(:translation_language_id =>TranslationLanguage.where{iso_code == 'fr'}.first.id,
      :calmapp_version_id => CalmappVersion.where {calmapp_id == Calmapp.where {name == 'calm_registrar'}.first.id}.first.id)
    
    #TranslationLanguage.where{name == 'French'}.first
    log.info("trannie created")

          

   CalmappVersionsTranslationLanguages.joins{calmapp_version}.joins{translation_language}.
=end
   end
=begin 
private
  # Others should use current_permission for its lazy initialisation. So making sure no one accesses current_permission_id
  # this works because active record uses 'method missing' to access the methods dynamically created by active record
  # Now active record will not get 'method missing' but the private method
  def current_permission_id
    self[:current_permission_id]
  end


=end
end # class
# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     not null
#  encrypted_password     :string(128)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetimecollection_check_boxes
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  failed_attempts        :integer         default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  username               :string(255)     not null
#  actual_name            :string(255)
#  current_permission_id  :integer         not null
#  created_at             :datetime
#  updated_at             :datetime
#

#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: venue_allocation_schemes
#
# * id                   :integer         not null
#   name                 :string(255)
#   allocation_scheme_id :integer
#   venue_id             :integer
#   created_at           :datetime        not null
#   updated_at           :datetime        not null
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
