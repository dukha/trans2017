class CalmappUser < ActiveRecord::Base
  belongs_to :calmapp
  belongs_to :user
  
  #validates  :calmapp_id, :presence=>true
  #validates  :user_id, :presence=>true
end
