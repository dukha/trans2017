class CavsTlTranslator < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'translator_id'
  belongs_to :calmapp_versions_translation_language, :foreign_key => 'cavs_translation_language_id' 
  
  validates :translator_id, :uniqueness => {:scope => :cavs_translation_language_id} 
 
end