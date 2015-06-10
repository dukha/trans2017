class Contact < ActiveRecord::Base
  validates :description, :presence => true
  belongs_to :user
  
  #has_many :contact_responding_admins, :class_name => "ContactRespondingAdmin", :dependent => :destroy
  #has_many :responding_admins, :through => :contact_responding_admins, :class_name => "User"
  after_create :mail_to_admins
  
  def mail_to_admins
    puts "mail_to_admins"
  end
end
