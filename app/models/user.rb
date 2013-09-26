class User < ActiveRecord::Base
#  # Include default devise modules. Others available are:
#  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
#  devise :invitable, :database_authenticatable, :registerable,
#         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, omniauthable:, Confirmable, :rememberable, :validatable, :encryptable, :recoverable
  devise  :database_authenticatable, :registerable,
         :trackable, :validatable,
         :timeoutable, :lockable #,:timeout_in => 10.minutes use value from  config/initializers/devise.rb

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :username, :login, :actual_name

  # username is unique by DB index :unique => true
  # username is required by DB :null => false
  validate :email, :username, :unique => true

  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  # these relationships model the configured access permissions
  has_many :permissions, :dependent => :destroy
  has_many :organisations, :through => :permissions

  # has_current_permission is a method in user which guarantees that there is a 
  # current permission. It is called on creation because of the validate
  #validate :has_current_permission
  # after_save :has_current_permission

  # Long story cut short: It does not work to store current_permission in a non-persistent attribute
  # (e.g. virtual attribute: attr_accessor :current_permission)
  # because each controller may recreate current_user from persistent storage and 
  # then current_permission is lost! 
  # declarative_auth wants method role_symbols to return roles. The users roles depend on the current permission
  # Therefore the current permission cannot be stored in the session but must be remembered by the user. The current permission
  # persists over consecutive sessions. Models cannot access the session!

  # return nil or a Permission for self
  def permission_at_organisation_named (name)
    org = Organisation.find_by(name: name)
    if org.nil?
      return nil
    end
    perms = permissions.select {|p| p.organisation  == org}
    if perms.size >1
      raise Error "User #{username} has more than one Permission for organisation #{name}"
    end
    if perms.empty? 
      nil
    else
      perms.first
    end
  end
 
  # Used as getter method:
  # return the current permission as it was persisted
  # if no current permission was set then do so now
  # Used as setter:
  # set the attribute
  def current_permission(perm=nil)
    #require 'ruby-debug'; debugger

    if perm.nil? #getter method
      if current_permission_id
        begin
          Permission.find current_permission_id
        rescue ActiveRecord::RecordNotFound
          return nil
        end
      else
        # current is not set
        if self.permissions.empty?
          # no permission exists for this user
          return self.add_permission  make_current: true
        end
        # the last added one is taken as default
        self.current_permission = self.permissions.last
        self.save
        return self.current_permission  # recursive, will end this time
      end
    else  # setter method
      write_attribute :current_permission_id, perm.id
    end
  end
  alias_method :current_permission=, :current_permission   #setter and getter

  def add_permission options={}
    # the default options:
    options={location: Location.empty_organisation, profile: Profile.guest, make_current: false}.merge(options)
    # each permission belongs to only one user! so we have to get a new one. It will be save with the user
    perm = Permission.new  :organisation => options[:location], :profile =>  options[:profile]
    self.permissions << perm
    if options[:make_current]
      self.current_permission = perm
    end
    self.save
    return perm
  end

  def remove_permission perm
    if self.permissions.include? perm
      if self.current_permission == perm
        self.current_permission = nil
      end
      self.permissions.delete(perm)
      perm.destroy
      self.save
      self.reload
    end
  end

  # return a printable representation of the organisation where self is currently logged in.
  # todo: should use method current_organisation
  def greeting
    if current_permission.nil?
      return "You need to select an organisation to work for!"
    end
    if current_permission.organisation.nil?
       return "Error: My current permission has no organisation"
    end
    "#{current_permission.organisation.name}"
  end

  # todo: either remove def current_organisation_name or implement it using current_organisation
  def current_organisation_name
    if current_permission.nil?
      return "You need to select an organisation to work for!"
    end
    if current_permission.organisation.nil?
       return "Error: My current permission has no organisation"
    end
    current_permission.organisation.name
  end

  def current_organisation
    if current_permission.nil?
      return "You need to select an organisation to work for!"
    end
    if current_permission.organisation.nil?
       return "Error: My current permission has no organisation"
    end
    return current_permission.organisation
  end

=begin
     for declarative auth
     Returns the role symbols of the given user for declarative_auth. 
=end
  def role_symbols
    if current_permission.nil? 
      # if you have no permissions then you are a guest
      # this role is not assigned anywhere else!
      [:guest]
    else
      #binding.pry
      current_permission.profile.roles.collect {|role|role.to_sym}
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
      u.add_permission location: Location.world, profile: Profile.sysadmin, make_current: true
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

private
  # Others should use current_permission for its lazy initialisation. So making sure no one accesses current_permission_id
  # this works because active record uses 'method missing' to access the methods dynamically created by active record
  # Now active record will not get 'method missing' but the private method
  def current_permission_id
    self[:current_permission_id]
  end

end

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
#  current_sign_in_at     :datetime
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
