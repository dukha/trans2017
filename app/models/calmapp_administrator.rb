class CalmappAdministrator < ActiveRecord::Base
  belongs_to :calmapp
  belongs_to :user
  
  #validates :user_id, :calmapp_id, presence: true
  validates :user_id, :uniqueness => {:scope=> :calmapp_id}
end
