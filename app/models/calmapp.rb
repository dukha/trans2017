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
  
  

  validates :name, :presence=>true, :uniqueness=>true
 
  def show_me
    return "APP " + name  + " app-id = " + id.to_s
  end
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
  def self.demo
    reg = Calmapp.create!( :name=>"calm_registrar")
    trans = Calmapp.create!(:name=>"translator")
  end  
  
  def can_destroy?
    return false
    #return (not new_record?) && calmapp_versions.empty?
  end
 
end
