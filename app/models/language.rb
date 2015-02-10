=begin

 Language of the translation application
 
=end

class Language < ActiveRecord::Base
  #set_table_name :language
  #has_many :calmapp_versions_languages
  #has_many :calmapp_versions, :through => :calmapp_versions_language

  validates :iso_code, :name, :presence => true,:uniqueness => true
  validates :name, :presence => true, :uniqueness => true

  #attr_accessible :iso_code, :name #,  :calm_reg_language, :course_l
  
  #validates_with VenueValidator
  

  
end

#

