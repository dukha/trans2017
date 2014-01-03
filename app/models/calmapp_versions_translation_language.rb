# == Schema Information
# Schema version: 20110918232413
#
# Table name: calmapp_versions_languages
#
#  id                 :integer         not null, primary key
#  calmapp_version_id :integer         not null
#  language_id        :integer         not null
#

class CalmappVersionsTranslationLanguage < ActiveRecord::Base
  include Validations
  belongs_to :calmapp_version
  belongs_to :translation_language

  validates :translation_language_id, :uniqueness => {:scope=> :calmapp_version_id}
  validates :calmapp_version_id, :uniqueness => {:scope=> :translation_language_id}
  #validates :calmapp_version, :existence=>true
  #validates :language, :existence=>true
  #attr_accessor :write
  def name
    return CalmappVersion.find(calmapp_version_id).name + " " + TranslationLanguage.find(translation_language_id).name
  end
  
  def self.find_by_language_and_version language_id, version_id
    where{calmapp_version_id == version_id}.where{translation_language_id == language_id}
    
  end
  
  def self.find_languages_not_in_version  language_ids_array, version_id
    where{calmapp_version_id == version_id}.where{translation_language_id << language_ids_array}
  end
end
