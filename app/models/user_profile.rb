class UserProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :profile
  
  validates :user_id, :uniqueness => {:scope=> :profile_id}
end
