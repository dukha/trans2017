class Contact < ActiveRecord::Base
  extend SearchModel
  include SearchModel
  validates :description, :presence => true
  belongs_to :user
  
  #has_many :contact_responding_admins, :class_name => "ContactRespondingAdmin", :dependent => :destroy
  #has_many :responding_admins, :through => :contact_responding_admins, :class_name => "User"
  after_commit :mail_to_admins, on: :create
  
  def mail_to_admins()
    responders = User.contact_responders
    
    responders.each{|r|
      AdminMailer.new_contact_from_user(id, r.id).deliver_now      
    }
  end
  
  
end
