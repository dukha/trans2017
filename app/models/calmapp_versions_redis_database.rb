class CalmappVersionsRedisDatabase < ActiveRecord::Base
  include Validations
  attr_accessible :calmapp_version,:calmapp_version_id, :release_status_id, :release_status, :redis_database, 
                 :redis_database_id, :redis_database_attributes
  attr_accessor :redis_instance_id, :redis_db_index
  
  belongs_to :calmapp_version_rd,  :class_name=> "CalmappVersion", #:foreign_key=>"calmapp_version_id", 
             :inverse_of=> :calmapp_versions_redis_database
  belongs_to :release_status
  belongs_to :redis_database
  accepts_nested_attributes_for :redis_database, :reject_if => :all_blank, :allow_destroy => true
  
  
  validates :calmapp_version_id, :presence=>true
  #validates :calmapp_version_id, :existence => true
  
  validates :release_status, :presence=>true, :existence=>true
  validates :release_status, :uniqueness=>{:scope=>[:calmapp_version]}
  validates :release_status_id, :existence=>true
end