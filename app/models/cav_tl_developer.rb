class CalmappDeveloper < ActiveRecord::Base
  #belongs_to :calmapp_version
  #belongs_to :user
  belongs_to :user, :foreign_key => 'user_id'
  belongs_to :calmapp_versions_translation_language, :foreign_key => 'cavs_translation_language_id' 
  
  validates :user_id, :uniqueness => {:scope=> :cavs_translation_language_id}
  #validates  :calmapp_id, :presence=>true
  #validates  :user_id, :presence=>true
end
