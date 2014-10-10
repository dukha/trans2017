class CalmappVersionsRedisDatabase < ActiveRecord::Base
  include Validations
=begin  
  attr_accessible :calmapp_version,:calmapp_version_id, :release_status_id, :release_status, :redis_database, 
                 :redis_database_id, :redis_database_attributes
=end
 attr_accessor :redis_instance_id, :redis_db_index
  
  belongs_to :calmapp_version#_rd,  :class_name=> "CalmappVersion", #:foreign_key=>"calmapp_version_id", :inverse_of=> :calmapp_versions_redis_database
  belongs_to :release_status
  belongs_to :redis_database
  accepts_nested_attributes_for :redis_database, :reject_if => :all_blank, :allow_destroy => true
  
  
  validates :calmapp_version_id, :presence=>true
  validates :calmapp_version_id, :existence => true
  
  # if this validation is there then the has_many through won't work in a nested form...
  #validates :redis_database_id, :presence=>true
  #validates :redis_database_id, :existence => true
  
  validates :release_status_id, :presence=>true, :existence=>true
  #validates :release_status_id, :uniqueness=>{:scope=>[:calmapp_version_id]}
  validates :release_status_id, :existence=>true
  
  #validate :redis_database_attributes_present
  
  def redis_database_attributes_present
    if redis_database.redis_db_index ==nil then
      
      add_to_base("Redis_db_index cannot be null")
    end  
  end
  
  def name
    return CalmappVersion.find(calmapp_version_id.name + " " + TranslationLanguage.find(translation_language_id).name)
  end
end