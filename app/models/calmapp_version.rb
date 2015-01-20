class CalmappVersion < ActiveRecord::Base
  #require 'validations'
  include Validations
  #languages available is a virtual attribute to allow languages_available to be used in the new form
  # :add_languages, :new_redis_db are virtual attributes for the user to indicate that a languages and redis database are to be added at the same time as a new version
  attr_accessor :translation_languages_available, :add_languages, :new_redis_dev_db, :translation_languages_assigned, 
         :warnings
=begin
  attr_accessible   :calmapp_id, :version,  
         :redis_databases, :translation_languages, :translation_languages_available, 
         :cavs_translation_language_id, :calmapp_versions_translation_languages_attributes, 
         :calmapp_versions_redis_database, :calmapp_versions_redis_database_attributes, 
         :redis_databases_attributes, :calmapp_versions_translation_language_ids#, :language_ids, :new_redis_dev_db
=end  
  belongs_to :calmapp #, :class_name => "Application", :foreign_key => "calmapp_id"
  
  has_many :calmapp_versions_redis_database#, :inverse_of=>:calmapp_version_rd, 
           #:class_name => "CalmappVersionsRedisDatabase",
             #:foreign_key=>"calmapp_version_id"
  accepts_nested_attributes_for :calmapp_versions_redis_database, :reject_if => :all_blank, :allow_destroy => true
  
  has_many :redis_databases, :through =>:calmapp_versions_redis_database#, :source=>:calmapp_version_rd
  #accepts_nested_attributes_for :redis_databases, :reject_if => :all_blank, :allow_destroy => true
 
  validates  :version,  :presence=>true, :uniqueness=>{:scope =>:calmapp_id}
  #validates :version, :numericality=>true#=> {:only_integer=>false, :allow_nil =>false}
  
  #validates :calmapp, :presence=>true

  has_many :calmapp_versions_translation_languages, :dependent => :destroy, :inverse_of => :calmapp_version_tl,
            :foreign_key=> "calmapp_version_id"
  accepts_nested_attributes_for :calmapp_versions_translation_languages, :reject_if => :all_blank, :allow_destroy => true
  has_many :translation_languages , :through => :calmapp_versions_translation_languages
  #validates :calmapp_id, :existence=>true
  
  # should be after_save, however we can't do this
  #after_update :add_english
  after_create :add_english
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
    return calmapp_name.humanize + " version " + version.to_s
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
  # Returns translation_languages not already assigned to this course, but not english
  def already_added_translation_languages_not_en
    translation_languages - en_in_array
  end
  
  def en_in_array
    [TranslationLanguage.find_by(iso_code: 'en')]
  end
  
  def available_translation_languages
      return TranslationLanguage.all - en_in_array - already_added_translation_languages_not_en
  end
   
  def to_s
    name
  end
  
  def self.version_select
    joins("join calmapps on calmapp_id = calmapps.id ").order( "calmapps.name asc")
  end
  def add_english
    puts "after save in add_english"
    #binding.pry
    english = TranslationLanguage.where{iso_code == 'en'}.first
    english_id = english.id
    if translation_languages.where{id == my{english_id}}.empty?#bsearch{ |x|   x.id == english_id }
        translation_languages <<  english
        puts "ADD_EN"
    else
      "DONT ADD EN"
    end
  end
end



