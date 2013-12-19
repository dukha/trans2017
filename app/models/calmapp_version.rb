class CalmappVersion < ActiveRecord::Base
  #require 'validations'
  include Validations
  #languages available is a virtual attribute to allow languages_available to be used in the new form
  # :add_languages, :new_redis_db are virtual attributes for the user to indicate that a languages and redis database are to be added at the same time as a new version
  attr_accessor :translation_languages_available, :add_languages, :new_redis_dev_db, :translation_languages_assigned
  attr_accessible   :calmapp_id, :version,  :redis_database, :translation_languages, :translation_languages_available, 
  :calmapp_versions_translation_language_ids, :calmapp_versions_translation_languages_attributes#, :language_ids, :new_redis_dev_db
  
  belongs_to :calmapp #, :class_name => "Application", :foreign_key => "calmapp_id"
  
  has_many :redis_databases
  accepts_nested_attributes_for :redis_databases, :reject_if => :all_blank, :allow_destroy => true
 
  validates  :version,  :presence=>true
  validates :version, :numericality=>true#=> {:only_integer=>false, :allow_nil =>false}
  
  #validates :calmapp, :presence=>true

  has_many :calmapp_versions_translation_languages, :dependent => :destroy
  accepts_nested_attributes_for :calmapp_versions_translation_languages, :reject_if => :all_blank, :allow_destroy => true
  has_many :translation_languages , :through => :calmapp_versions_translation_languages
  #validates :calmapp_id, :existence=>true
  
  
  
=begin
@return a collection of all calmapp names with versions
=end
  def self.calmapp_names_with_versions
     calmapps = Calmapp.all
    name_versions = []
    calmapps.each{ |app|
       app.calmapp_versions.each{|version|
         name_versions << app.calmapp_name_with_version
       }
     }
     name_versions.sort!
     return name_versions
  end
  
  # return a concatenation of name and version suitable for display
  def calmapp_name_with_version
    return calmapp_name + " version " + version.to_s
  end
  def name
    return calmapp_name_with_version
  end
  def calmapp_name
    #puts "xxxx" + Application.where(:id => application_id).name
    return Calmapp.where(:id => calmapp_id).first.name
  end
  # moved to validations lib
  #def self.validate_version version
    ##return version.match( regex)
  #end

  # Don't confuse the virtual attribute translation_languages_available that is just to keep AR happy
  # Returns translation_languages not already assigned to this course.
  def available_translation_languages
      return TranslationLanguage.all - translation_languages
  end
  
  
end

# == Schema Information
#
# Table name: calmapp_versions
#
#  id         :integer         not null, primary key
#  calmapp_id :integer         not null
#  version    :integer         not null
#  created_at :datetime
#  updated_at :datetime
#

