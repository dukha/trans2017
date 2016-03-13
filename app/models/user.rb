class User < ActiveRecord::Base
  extend SearchModel
  include SearchModel
  
  devise  :database_authenticatable, :registerable,
         :trackable, :validatable,
         :timeoutable, :lockable, :invitable, :invite_key => {:email=>'', :actual_name=>'' } #,:timeout_in => 10.minutes use value from  config/initializers/devise.rb
  
  before_validation :check_username
  after_invitation_accepted :notify_admin

  validates :email, :username, :uniqueness => true
  validates :email, presence: true
  validates :actual_name, :uniqueness => true
  validates :actual_name, presence: true
  validates :username, :uniqueness => true
  validates :username, presence: true
  validate :password_complexity
  validates :country, :phone, presence: true, :if => Proc.new { |record| !record.new_record? }
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login, :via_invitable
  #The above are being replaced by those below. Keep both for now. mfl
  has_many :user_profiles, :dependent => :destroy
  #accepts_nested_attributes_for :user_profiles, :reject_if => :all_blank, :allow_destroy => true
  has_many :profiles, :through => :user_profiles
  
  has_many :translator_jobs, :foreign_key => "translator_id" , :class_name=> "CavsTlTranslator", :dependent => :destroy
  #accepts_nested_attributes_for :translator_jobs, :reject_if => :all_blank, :allow_destroy => true
  has_many :translator_cavs_tls, :through => :translator_jobs, :source => :calmapp_versions_translation_language
  
  has_many :developer_jobs, :foreign_key => "user_id" , :class_name=> "CavsTlDeveloper", :dependent => :destroy 
  #accepts_nested_attributes_for :developer_jobs, :reject_if => :all_blank, :allow_destroy => true
  has_many :developer_cavs_tls, :through => :developer_jobs, :source => :calmapp_versions_translation_language#, :class_name=>"Calmapp"
  
  has_many :administrator_jobs, :foreign_key => "user_id" , :class_name=> "CavsTlAdministrator", :dependent => :destroy
  has_many :administrator_cavs_tls, :through => :administrator_jobs, :source => :calmapp_versions_translation_language
  def password_complexity
    if via_invitable
      return true
    end
    if persisted?
       if sign_in_count == 0 && confirmed_at.nil?
        #confirmation_token is now not longer used
        # a pw is now used by devise_inviter so just accept the invitation pw as valid
        return true
      end
    end
    
    if password.present? && (! /^(?=.{8,})(?=.*[\W])(?=.*\d)./.match(password))  #/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d). /
      errors.add( :password, 
      "must be at least 8 characters long, include at least one special character like !@#\$%^&*() and one digit")  #"must include at least one lowercase letter, one uppercase letter, and one digit"

    end
  end

  def self.searchable_attr
    %w(email actual_name user_name)
  end
  
  def self.sortable_attr
    %w(email actual_name user_name)
  end
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
  
      # below is the code for using the permissions model
      #current_permission.profile.roles.collect {|role|role.to_sym}
      
      # now using 1 user has 1 profile model (actually many but at the moment UI only allows for 1)
      # This code here allows for more than 1 profile
      role_array = []
      profiles.collect { |p| role_array = role_array + p.roles}
      return roles = role_array.flatten.uniq.collect { |r| r.to_sym}  
    end   
  end
  def developer?
    return developer
  end
  def translator?
    return translator
  end
  def application_administrator?
    application_administrator
  end
  def sysadmin?
    return profiles.include?(Profile.where{name == "sysadmin"}.first)
  end
  def admin?
    return application_administrator? || sysadmin?
  end
  
  def has_user_permission_on_cavtl(calmapp_version_translation_language)
        return true if profiles.include?(Profile.where{name == 'sysadmin'}.first)
        return true if developer_cavs_tls.include?(calmapp_version_translation_language)
        return true if translator_cavs_tls.include?(calmapp_version_translation_language)
        return true if administrator_cavs_tls.include?(calmapp_version_translation_language)
        return false
  end
  
  def list_cavtls_for_user
    return CalmappVersionsTranslationLanguage.all if profiles.include?(Profile.where{name == 'sysadmin'}.first)
    return (developer_cavs_tls + translator_cavs_tls  + administrator_cavs_tls).uniq
  end  
  def self.create_root_user
    
    username = "rooter"
    pw = Rails.application.secrets.rooter #ENV[username]#
    u = User.find_by_username username
    if u
       result = User.update u.id, :password => pw,:password_confirmation => pw
       puts "result==#{result}"
       puts "Resetting password"
       puts "Your new password: '#{pw}'"
    else
     
      param = {:password => pw,:password_confirmation => pw,:username => username,
        :email => 'root@localhost.localdomain', :actual_name=> 'root', 
        :country=> 'Australia', :phone => '819999'}
      puts "creating user"
      u = User.create! param
      puts "creating permission"
  
      u.profiles << Profile.sysadmin
      
      u.reload

      puts "Added user #{username} with permission "
      puts "Password: '#{pw}'"
      puts "end of create_root_user"
    end
  end
   
=begin
 Creates root,mark 
=end
  def self.seed
    
    puts '**************'
    puts Rails.env
    puts '***************'
     User.create_root_user
     pw = Rails.application.secrets.mark#ENV["mark"]#'!1234567'
     param = {:password => pw,:password_confirmation => pw,:username => 'mark',:email => 'mplennon@gmail.com', 
                :actual_name=> 'Mark Lennon', :country=> 'Australia', :phone => '07 5475 1065', :responds_to_contacts => true}
     admin = User.create! param
     admin.profiles << Profile.sysadmin
     
  end
=begin
 Creates albert (sysadm), devvie, addy, trannie
=end  
  def self.demo
    pw = '!123456!'
    param = {:password => pw,:password_confirmation => pw,:username => 'albert',:email => 'albert@calm.org', 
              :actual_name=> 'albert', :country=> 'Australia', :phone => '213000'}
    
    albert = User.create! param
    albert.profiles << Profile.sysadmin
    
    param = {:password => pw,:password_confirmation => pw,:username => 'a',:email => 'a@calm.org', 
              :actual_name=> 'a', :country=> 'Australia', :phone => '2459999'}
    a = User.create! param
    a.profiles << Profile.sysadmin
    
    param[:username]='devvie'
    param[:actual_name] = 'Developer User'
    param[:email]= 'developer@calm.org'
    param[:developer] = true
    param[:country]= 'Australia' 
    param[:phone] = '456000'
    developer=User.create! param
    developer.profiles << Profile.where {name == "developer"}.first

    developer.developer_cavs_tls << CalmappVersionsTranslationLanguage.joins(:calmapp_version_tl).where{calmapp_version_tl.version  == "4" }.
       joins(:translation_language).where{translation_language.iso_code =='en'}.first
    log.info("devvie created")
    
    param[:username]='addy'
    param[:actual_name] = 'Application Admin'
    param[:email]= 'addy@calm.org'
    param[:application_administrator] = true
    param[:country]= 'Australia' 
    param[:phone] = '111111111'
    admin=User.create! param
    admin.profiles << Profile.where {name == "application_administrator"}.first

    admin.administrator_cavs_tls = CalmappVersionsTranslationLanguage.joins(:calmapp_version_tl).where{calmapp_version_tl.version  == "4" }.all
    
    log.info("addy created")
    
    param[:username]= 'trannie'
    param[:actual_name] = 'Translator User'
    param[:email]= 'translator@calm.org'
    param[:translator] = true
    param[:country]= 'Australia' 
    param[:phone] = '3400000000'
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
            
    translator.translator_cavs_tls << cav_4_cs
    translator.translator_cavs_tls << cav_4_fr 
    translator.translator_cavs_tls << 
       CalmappVersionsTranslationLanguage.new(:translation_language_id =>TranslationLanguage.where{iso_code == 'ja'}.first.id,
      :calmapp_version_id => CalmappVersion.where {calmapp_id == Calmapp.where {name == 'calm_registrar'}.first.id}.first.id)

   #reg4 = CalmappVersion.where {calmapp_id == Calmapp.where {name == 'calm_registrar'}.first.id}.first
   
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
   
  def self.contact_responders
     return User.where{responds_to_contacts == true}.to_a#load
   end
  def roles_list
   roles = []
   roles << "Translator" if ! translator_cavs_tls.empty?
   roles << "Developer" if ! developer_cavs_tls.empty?
   roles << "Administrator" if ! administrator_cavs_tls.empty?
   return roles.join(" or ")
  end
  
  def all_cavtl_permissions
    #binding.pry
    if sysadmin?
      arr = CalmappVersionsTranslationLanguage.all
    else
      arr = translator_cavs_tls + developer_cavs_tls + administrator_cavs_tls
    end
    return arr.uniq
  end
=begin
 Translators need a special permission to publish their work.
 They can only publish a version_language to the designated translation test redis
 This gives the list of what can be published  
=end  
  def self.what_translations_can_user_publish user
    cavs_list = []
    publishable = user.all_cavtl_permissions.each{ |cavtl|#translator_cavs_tls.each{ |cavtl|
     translator_rdb = cavtl.calmapp_version_tl.translators_redis_database   
     cavs_list << translator_rdb unless translator_rdb.nil?
    }
    return cavs_list.uniq
  end
 
 protected
 # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
 # Overwrite Devise’s find_for_database_authentication method

   def self.find_for_database_authentication(warden_conditions)
     conditions = warden_conditions.dup
     login = conditions.delete(:login)
     where(conditions).where(["username = :value OR email = :value", { :value => login }]).first
   end
  
    def self.developers
      return where{developer == true}
    end
  
   def self.translator
     return where{translator == true}
   end
   
   def self.administrator
     return where{administrator == true}
   end

private
  def check_username

    if username.blank? then
      if not actual_name.blank? then
        # make username equal to actual_name without whitespace
      
        self.username = actual_name.gsub(/\s+/, "")
        puts username
      end  
    end
  end  
   
  def notify_admin
    puts "NOTIFY ADMIN"
    
    AdminMailer.user_invitation_accepted(self).deliver_later
  end 
   
end # class
