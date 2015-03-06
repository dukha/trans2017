# == Schema Information
# Schema version: 20110918232413
#
# Table name: calmapps
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

=begin
  Every calmapp will have a number of translation files plus use common files.
  This class is the calmapp that owns translation files
  Shared (common) translation files are kept in an calmapp called Shared
=end
class Calmapp < ActiveRecord::Base
  
  attr_accessor :new_version#,  :new_redis_db#, :add_languages

  has_many :calmapp_versions, :dependent => :restrict_with_exception
  accepts_nested_attributes_for :calmapp_versions, :reject_if => :all_blank, :allow_destroy => true
  
  has_many :developer_jobs, :foreign_key => "calmapp_id" , :class_name=> "CalmappUser"
  #accepts_nested_attributes_for :developer_jobs, :reject_if => :all_blank, :allow_destroy => true
  has_many :developers, :through => :developer_jobs, :source => :user,  :class_name => "User"#, :foreign_key => :user_id 
=begin
  These attributes permit the adding of version and languages info in the calmapp screen in a new record
  add_first_version boolean indicating the user wants to add extra data
  version_name the name of the version to be added
  add_non_english_languages boolean indicating the users intent
  language_ids is a collection of the language i's for the non english languages to be added
=end
  #attr_accessor :add_first_version, :version_name, :add_non_english_languages, :language_ids
  #attr_accessible :name, :calmapp_versions#:new_version  #,  :new_redis_db  #, :language_ids

  #attr_accessor :selection_mode
  #validates :languages, :associated => true
  #validates :calmapp_versions, :associated => true
  validates :name, :presence=>true, :uniqueness=>true
 
  
=begin  
  def save_app_version_database_languages(version=nil, redis_database=nil, languages=nil )
      Calmapp.transaction do
        save!
        if ! version.nil? then
          version.calmapp_id = id
          if languages != nil then
            version.languages=languages
          end
          the_version = calmapp_versions.create!(version.attributes)
          if the_version then
            if languages != nil then
              the_version.languages=languages
            end
            
            if ! redis_database.nil? then
              # this line sets the has_one association and saves it to the database.
              the_version.redis_database= redis_database
            end
          end
        end
      end # calmapp transaction
    return self
  end #save_app_version_database
=end
  def can_destroy?
    return (not new_record?) && calmapp_versions.empty?
  end
end
