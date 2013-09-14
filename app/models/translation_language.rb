=begin

 Represents a (virtual)location used for all translations in a specific language
 
=end

class TranslationLanguage < ActiveRecord::Base
  #set_table_name :language
  has_many :calmapp_versions_languages
  has_many :calmapp_versions, :through => :calmapp_versions_language
  has_many :translations_uploads
  
  validates :iso_code, :name, :presence => true,:uniqueness => true
  validates :name, :presence => true, :uniqueness => true
  
  attr_accessible :iso_code, :name #,  :calm_reg_language, :course_l
  
  #validates_with VenueValidator
  
=begin 
  def allow_organisation_child?
    false
  end

  def allow_area_child?
    false
  end

  def allow_translation_language_child?
    false
  end

  # return false if self would not be under an organisation
  def allow_to_be_translation_language?
    has_organisation_ancestor?
  end

  
  def self.accessible_translation_languages(current_user)
    return current_user.current_organisation.accessible_translation_languages
  end
=end
  
end

# == Schema Information
#
# Table name: locations
#
#  id               :integer         not null, primary key
#  name             :string(255)     not null
#  type             :string(255)     not null
#  parent_id        :integer
#  translation_code :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  marked_deleted   :boolean         default(FALSE)
#

