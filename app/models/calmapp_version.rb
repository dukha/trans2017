class CalmappVersion < ActiveRecord::Base
  #require 'validations'
  include Validations
  #languages available is a virtual attribute to allow languages_available to be used in the new form
  attr_accessor :translation_languages_available, :add_languages, :new_redis_dev_db, 
           :translation_languages_assigned, 
         :warnings, :previous_id

  belongs_to :calmapp #, :class_name => "Application", :foreign_key => "calmapp_id"
  
  has_many :redis_databases, inverse_of: :calmapp_version#, :through =>:calmapp_versions_redis_database#, :source=>:calmapp_version_rd
  accepts_nested_attributes_for :redis_databases, :reject_if => :all_blank, :allow_destroy => true
  
  belongs_to :translators_redis_database, foreign_key: "translators_redis_database_id", class_name: "RedisDatabase"
  belongs_to :production_redis_database, foreign_key: "production_redis_database_id", class_name: "RedisDatabase"
  validates  :version,  :presence=>true, :uniqueness=>{:scope =>:calmapp_id}
  validate :only_1_production_db_for_translators, 
           :production_db_not_same_as_test_for_translators, 
           :only_1_test_db_for_translators,
           :test_db_for_translators_not_prod_release_status,
           :prod_db_for_translators_prod_release_status
  #validate :only_1_translator_database
  has_many :calmapp_versions_translation_languages, :dependent => :restrict_with_exception, 
            :inverse_of => :calmapp_version_tl,
            :foreign_key=> "calmapp_version_id"
  accepts_nested_attributes_for :calmapp_versions_translation_languages, :reject_if => :all_blank, :allow_destroy => true
  has_many :translation_languages , :through => :calmapp_versions_translation_languages
  
  # should be after_save, however we can't do this
  #after_update :add_english
  before_create :do_before_create,   :if => Proc.new { |cav| cav.copied_from_version.blank? }
  after_commit :do_after_commit, :on=>[:create, :update]
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
  
   def do_after_commit
    #binding.pry
    # As we are handling all redis db's for this version then we initialise these 2 columns first
    update_column("translators_redis_database_id", nil)
    update_column("production_redis_database_id", nil)
    redis_databases.each{ |db|
      #binding.pry
      
      if db.used_by_publishing_translators == 1
        #calmapp_version.update_columns(:translators_redis_database_id => id)
        #update_columns(:used_by_publishing_translators => -1)
        update_column("translators_redis_database_id", db.id)
        db.update_columns(:used_by_publishing_translators => -1)
      elsif db.used_by_publishing_translators == 0  
        #calmapp_version.update_columns(:translators_redis_database_id => nil)
        #update_columns(:used_by_publishing_translators => -1)
        #update_column("translators_redis_database_id", nil)
        db.update_columns(:used_by_publishing_translators=> -1)
      end
      
      if db.used_by_production_publishers == 1
        #calmapp_version.update_columns(:production_redis_database_id => id)
        #update_columns(:used_by_production_publishers => -1)
        update_column("production_redis_database_id", db.id)
        db.update_columns(:used_by_production_publishers => -1)
      elsif db.used_by_production_publishers == 0 
        #calmapp_version.update_columns(:production_redis_database_id => nil)
        #update_columns(:used_by_production_publishers => -1)
        #update_column("production_redis_database_id", nil)
        db.update_columns(:used_by_production_publishers => -1)
      end
      
    } #Each
  end
  
  def prod_db_for_translators_prod_release_status
    puts "in prod_db_for_translators_prod_release_status()"
    # we have to validate this way as the real produciton db field is set after commit
    prod_dbs = []
    redis_databases.each{ |db|
      if db.used_by_production_publishers == 1 && db.release_status.status != "Production"
        str = "You cannot declare redis database, #{db.description},  to be used in PRODUCTION if it does not have release status Production (release_status = #{db.release_status.status}"
        errors.add(:redis_databases, str)   
      end     
         
    }    
  end
  def test_db_for_translators_not_prod_release_status
    puts "in test_db_for_translators_not_prod_release_status()"
    # we have to validate this way as the real produciton db field is set after commit
    test_dbs = []
    redis_databases.each{ |db|
      if db.used_by_publishing_translators == 1 && db.release_status.status == "Production"
        #binding.pry
        str = "You cannot declare redis database, #{db.description},  to be used in TEST if it has release status Production"
        errors.add(:redis_databases, str)   
      end     
         
    }    
  end
  def production_db_not_same_as_test_for_translators
    puts "in production_db_not_same_as_test_for_translators()"
     prod_dbs = []
    redis_databases.each{ |db|
      str = "#{db.description} is declared as both a test databases for translators and a production database for translator publishing. Remove one of these declarations."
       puts str
       #binding.pry
       errors.add(:redis_databases, str) if(db.used_by_production_publishers == 1 && db.used_by_publishing_translators == 1)
      }
  end
  def only_1_production_db_for_translators
    puts "in only_1_production_db_for_translators()"
    prod_dbs = []
    redis_databases.each{ |db|
       prod_dbs << db.description if db.used_by_production_publishers == 1
      
      }
    if prod_dbs.count > 1
      str = prod_dbs.join(", ")
      errors.add(:redis_databases, "Can only have 1 production redis database(for each Application Version) for translators to publish to: current #{str}")
    end  
  end
  
  def only_1_test_db_for_translators
    puts "in only_1_test_db_for_translators()"
    test_dbs = []
    redis_databases.each{ |db|
       test_dbs << db.description if db.used_by_publishing_translators == 1
      
      }
    if test_dbs.count > 1
      str = test_dbs.join(", ")
      errors.add(:redis_databases, "Can only have 1 test redis database(for each Application Version) for translators to publish to: current #{str}")
    end  
  end
  # return a concatenation of name and version suitable for display
  def calmapp_name_with_version
    return calmapp.name.humanize + " Version:" + version.to_s
  end
=begin  
  def name
    return calmapp_name_with_version
  end
=end  
  def description
    return calmapp_name_with_version
  end
  
  def calmapp_name
    return Calmapp.where(:id => calmapp_id).first.name.titlecase
  end

  def show_me
    return "CAV " + calmapp.show_me + " v:" + version.to_s + " cav-id = " + id.to_s
  end
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
  
  def translation_languages_not_en
    return translation_languages - en_in_array 
    
  end 
  def to_s
    description
  end
=begin  
  def translators_redis_db
    return RedisDatabase.find(translators_redis_database_id)
  end
=end  
  def self.version_select
    joins("join calmapps on calmapp_id = calmapps.id ").order( "calmapps.name asc")
  end
  def do_before_create
    #This must becalled before save as it ensures that en is the first language in the list
    # We don't need to delay this as it is a relatively short process
    add_english
  end
  def add_english
    puts "before create in add_english"
    english = TranslationLanguage.TL_EN 
    english_id = english.id
    #englsih must be first in the array fo translation_languages to be added
    en_first = false
    if calmapp_versions_translation_languages.empty?
      en_first = false
    elsif  calmapp_versions_translation_languages.first.translation_language.iso_code == english.iso_code
      en_first = true 
    end
    if ! en_first then
        arr = []
        calmapp_versions_translation_languages.each do |cavtl|
          arr<< cavtl
        end
        calmapp_versions_translation_languages.reset
        arr.delete_if {|cavtl| cavtl.translation_language_id == english_id}
        arr.insert(0, CalmappVersionsTranslationLanguage.new(:translation_language_id => english_id))
        arr.each{ |cavtl|
          calmapp_versions_translation_languages << cavtl
        } 
    
        puts "ADDED_EN"
    else
      "EN   already exxists first in array: not ADDED"
    end
  end
=begin
 deep copy copies all translation languages and translations for that version. It does not copy redis databases or uploads. 
 @param old_version is a version such as 4, '4', '1.2.3', 'longhorn'
 @param new_version is a version such as 4, '4', '1.2.3', 'longhorn'
 @param copy_translation_languages boolean indicator of what to do
 @param copy_translations  boolean indicator of what to do
=end  
  def deep_copy old_version_id, user, copy_translation_languages=true, copy_translations =true
    #old_version = CalmappVersion.find(old_version_id)
    if save
      if Rails.env.development? || Rails.env.test?
        FinishVersionDeepCopyJob.perform_now(old_version_id, self.id, user.id, copy_translation_languages, copy_translations )
      else  
        FinishVersionDeepCopyJob.perform_later(old_version_id, self.id, user.id, copy_translation_languages, copy_translations )
      end
      
      return true
    else
      return false  
    end 
    #version = CalmappVersion.new(:version => new_version.to_s ,:calmapp_id => old_version.calmapp_id, :copied_from_version => old_version.version)
    #raise StandardError.new version.errors.messages if version.invalid? 
    #if version.save then  
      
    #end# if save
  end
   
  
  def self.finish_deep_copy(old_version_id, new_version_id, user_id, copy_translation_languages, copy_translations)
    begin
      old_version = CalmappVersion.find(old_version_id)
      new_version = CalmappVersion.find(new_version_id)
      if copy_translation_languages then #&& ! copy_translations then
        new_version.translation_languages.concat(old_version.translation_languages)
        if copy_translations then
          old_version.calmapp_versions_translation_languages.find_each do |cavtl|
            CalmappVersionsTranslationLanguage.create!(:calmapp_version_id => version.id, :translation_language_id => cavtl.translation_language_id )
            Translation.where{cavs_translation_language_id == my{cavtl.id}}.find_each do |t|
              Translation.create!(:translation => t.translation, :dot_key_code => t.dot_key_code, :cavs_translation_language_id => cavtl.id) 
              
            end # each translation  
          end # each cavtl
        end #copy trans
      end #copy tl
      UserMailer.background_process_success(user, "Version_deep_copy", old_version.description + " to " + new_version.description)
    rescue StandardError => e
       Rails.logger.error "The deep copy of " + old_version.description + " has failed"
       Rails.logger.error "Deep copy exception: " +e.message
       Rails.logger.error e.backtrace.join("\n")
       UserMailer.background_process_fail(user_id, "Version_deep_copy", old_version.description + " to " + new_version.description, e.message)  
    end   #begin resuce 
  end
  def deep_destroy#(user)
    #if user.role_symbols.include?(:calmapp_versions_deepdestroy)
     begin
       transaction do
         redis_databases.find_each { |db| db.destroy }
         calmapp_versions_translation_languages.find_each { |cavtl|

           cavtl.deep_destroy
           }
         
         destroy  
       end #transaction
     rescue StandardError => e
       puts e.message
       raise  
     end #beginrescue
   # else
      
   # end #if else   
  end #def
  
  def self.demo
    reg4 = CalmappVersion.create!(:calmapp_id => Calmapp.where {name == 'calm_registrar'}.first.id, :version => 4)
    trans1=CalmappVersion.create!(:calmapp_id => Calmapp.where {name == 'translator'}.first.id, :version => 1)
  end
end #class



