class CalmappVersionsTranslationLanguage < ActiveRecord::Base
  include Validations
  extend SearchModel
  include SearchModel

  def self.searchable_attr 
     %w(calmapp_version_id translation_language_id )
  end
  def self.sortable_attr
      []
  end
  
  belongs_to :calmapp_version_tl, :inverse_of=>:calmapp_versions_translation_languages, :class_name => "CalmappVersion", :foreign_key =>"calmapp_version_id"
  belongs_to :translation_language
  has_many :translations, :foreign_key=> "cavs_translation_language_id"

  validates :translation_language_id, :uniqueness => {:scope=> :calmapp_version_id}
  validates :calmapp_version_id, :uniqueness => {:scope=> :translation_language_id}
  
  has_many :translations_uploads, :foreign_key=> "cavs_translation_language_id"
  accepts_nested_attributes_for :translations_uploads, :reject_if => :all_blank, :allow_destroy => true
  
  has_many :cavs_tl_translators, :foreign_key=> "cavs_translation_language_id"
  has_many :translators, :through => :cavs_tl_translators, :class_name => 'User', :source=> 'user'
  
  has_many :developer_jobs, :foreign_key => "cavs_translation_language_id" , :class_name=> "CavsTlDeveloper"
  has_many :developers, :through => :developer_jobs, :source => :user,  :class_name => "User", :foreign_key => :user_id 
  
  has_many :administrator_jobs, :foreign_key => "cavs_translation_language_id" , :class_name=> "CavsTlDeveloper"
  has_many :administrators, :through => :administrator_jobs, :source => :user,  :class_name => "User", :foreign_key => :user_id
  
  # once we have saved a new language then we upload the base file for that translation 
  after_create :base_locale_translations_for_new_translation_languages, :add_this_to_sysadmin_users
  after_commit :do_after_commit_on_create, :on => :create
  
=begin
 This class compares by description method 
 Below implements the Comparable interface
=end
=begin @deprecated
  def <=>(another)
    description <=> another.description
  end
=end
  def self.permitted_for_translators
     #all.load - [TranslationLanguage.TL_EN ]
     en_id = TranslationLanguage.TL_EN.id
     where{translation_language_id != my{en_id} }.load 
  end

  def self.permitted_for_developers
     #all.load - [TranslationLanguage.TL_EN ]
     en_id = TranslationLanguage.TL_EN.id
     where{translation_language_id == my{en_id} }.load 
  end
  def self.permitted_for_administrators
     all
  end
 
  def redis_databases
    return calmapp_version_tl.redis_databases
  end
 
  def redis_databases_count
    return redis_databases.count
  end
  
  def redis_databases_count_production
    #redis_databases.where{releases_status == "Production"}.count
    production_redis.count
  end
  def description
    return (calmapp_version_tl.description + " " + translation_language.name).titlecase
  end
  def show_me
    return "CAVTL " + calmapp_version_tl.show_me + " " + translation_language.show_me + " cavtl-id = " + id.to_s
  end
  
  def production_redis
    #binding.pry
    return calmapp_version_tl.redis_databases.
             where{release_status_id.in(ReleaseStatus.production_database_ids)}
  end
=begin
 Sysadmin profiled users must have access to all cav_tls for translation purposes 
=end
  def add_this_to_sysadmin_users
    puts "after commit in calmapp_versions_translation_language"
    users = User.includes(:profiles).where(profiles: { name: $SYSADMIN }).all
    users.each do |u|
      if not u.administrator_cavs_tls.include?(self) then
        u.administrator_cavs_tls << self
      end  
    end
  end  
=begin
 Uploads the base translation for a new language after added (ie created)
 saves new upload
=end
  def base_locale_translations_for_new_translation_languages

    puts "after save in base_locale_translations_for_new_translation_languages"
    
    uploads =  TranslationsUpload.where{cavs_translation_language_id == my{id}}.load
    found=false
    # Check to see that this is not a reupload
    if not uploads.empty? then
      # the file is already uploaded
      uploads.each do |u|
        # This doesn't always work: if u.yaml_upload.identifier == base_locale_file_name then
        if u.yaml_upload_identifier == base_locale_file_name then
          found=true
          return
        end
      end  #each       
    end # not empty
    if not found then
         # all the standard base files are in a rails dir as below (they havebeen downloaded from /home/mark/.rvm/gems/ruby-2.0.0-p247/gems/rails-i18n-4.0.1/rails/locale/)
        file_to_upload = File.join(TranslationsUpload.base_locales_folder,  base_locale_file_name())
        
        if File.exists?(file_to_upload) then          
          tu = TranslationsUpload.new(:cavs_translation_language_id=>id, 
               :yaml_upload=> File.open(file_to_upload) , :description=> "Automatic base locale upload " + base_locale_file_name())          
          tu.save
        else
          # The file may not exist, in which case we don"t write but warn"
          calmapp_version_tl.warnings=ActiveModel::Errors.new(self) if calmapp_version_tl.warnings.nil?
          calmapp_version_tl.warnings.add(:base, I18n.t($MS + "base_locale_file_not_found.warning", :folder => TranslationsUpload.base_locales_folder, :file_name=> base_locale_file_name,:fuchs=> "https://github.com/svenfuchs/rails-i18n/tree/master/rails/locale"))          #flash.now[:warning] = "The file " + base_locale_file_name + " does not exist in " + File.join(Rails.root, "base_locales") + " You will have to fill in about 160 more translations if you can't find this file. You can also copy and rename a file from a close locale. e.g. copy zh-CN.yml renaming to zh-MY.yml for Mayaysian Chinese."
          Rails.logger.warn "The file " + base_locale_file_name + " does not exist in " + TranslationsUpload.base_locales_folder + " You will have to fill in about 160 more translations if you can't find this file. You can also copy and rename a file from a close locale. e.g. copy zh-CN.yml renaming to zh-MY.yml for Mayaysian Chinese."
        end # base file exists
   end # not found
  end # def
  
  def do_after_commit_on_create
    if translation_language.iso_code != 'en' then
      #if Rails.env.development? || Rails.env.test?
        AddEnKeysForNewLanguageJob.set(:wait=>2.minutes).perform_later(id)
        #binding.pry
        CheckAllEnKeysAvailableInNewLangJob.set(:wait=> 5.minutes).perform_later(id)
      #else  
        #AddEnKeysForNewLanguageJob.set(:wait=> 2.minutes).perform_later(id)
        #binding.pry
        #CheckAllEnKeysAvailableInNewLangJob.set(:wait=> 5.minutes).perform_later(id)
      #end
      
    end
  end
  def add_all_dot_keys_from_en_for_new_translation_language #(cavtl_id)
    #puts "after commit on create : add_all_en_dot_keys_for_new_translation_languages"
    msg = "Callback: 'add_all_dot_keys_from_en_for_new_translation_language'. Adding new blank translations after for a new language in " + show_me
    Rails.logger.info(msg )
    puts msg

    begin
      cavtl = self #CalmappVersionsTranslationLanguage.find(cavtl_id)
      puts cavtl.to_s
      en_trans = Translation.single_lang_translations_arr("en", cavtl.calmapp_version_id).all
      #puts "English keys to be added" 
      
      count =0 
      en_trans.each do |en_t|
        foreign = Translation.where{dot_key_code == my{en_t.dot_key_code}}.where{cavs_translation_language_id == my{cavtl.id}}.first
        if not foreign.nil?
          #puts "dkc + tl.iso_code +  existing translation" 
          #puts foreign.dot_key_code + " " + foreign.calmapp_versions_translation_language.translation_language.iso_code + " " + foreign.translation.to_s 
        end
        test =  ActiveSupport::JSON.decode(en_t.translation)
        incomplete = false
        if test.is_a? Array
          length = test.length
          foreign_blank = ActiveSupport::JSON.encode( Array.new(length))
          incomplete = true
        elsif test.is_a? Hash
          
          blank = {}
          if en_t.special_structure == "plural"    
            plurals = translation_language.plurals
            plurals.each{ |pl| blank[pl] = nil}  
          else
            test.keys.each{ |k| blank[k] = '' }
          end  
          foreign_blank = ActiveSupport::JSON.encode(blank)
          incomplete = true
        else
          if Translation.valid_empty_string_dot_key_code.include?(en_t.dot_key_code) 
            foreign_blank = '' 
          else 
            foreign_blank =  nil 
          end  
        end #test is   
        if foreign.nil?
          begin
            new_t = Translation.create(
               :dot_key_code => en_t.dot_key_code, 
               :cavs_translation_language_id => cavtl.id,
               :translation => foreign_blank, 
               :incomplete=> incomplete)
         rescue Exception => e

         end    
         else

         end     
         puts "New translation added for dot_key: " + en_t.dot_key_code + " language: " + translation_language.name + " translation: '" + (foreign_blank.nil? ? "Nil": foreign_blank) 
         puts ""
        count = count + 1
      end # do t
      msg = "Successful completion of Callback: 'add_all_dot_keys_from_en_for_new_translation_language'. Count = " + count.to_s
      Rails.logger.info(msg)
      puts msg
    rescue StandardError => se
      msg = "Error in Callback: 'add_all_dot_keys_from_en_for_new_translation_language'."
      Rails.logger.error(msg)
      Rails.logger.error(se.message)
      Rails.logger.error(se.backtrace.join("\n"))
      puts msg
      puts se.message
      puts se.backtrace.join("\n")
      raise
    end  
  end
  
  def base_locale_file_name
    translation_language.iso_code + ".yml"
  end
  def self.find_by_language_and_version language_id, version_id
    where{calmapp_version_id == version_id}.where{translation_language_id == language_id}
    
  end
  
  def self.find_languages_not_in_version  language_ids_array, version_id
    # en is always in version
    # so we add it to the array
    language_ids_array << TranslationLanguage.TL_EN.id
    where{calmapp_version_id == version_id}.where{translation_language_id << language_ids_array}
  end
  def deep_destroy
     CalmappVersionsTranslationLanguage.destroy_dependents(self.id)
     delete
  end
  def self.destroy_dependents(id)
      transaction do
         cavtl = CalmappVersionsTranslationLanguage.find(id)
         cavtl.translations.find_each {|t| t.delete}
         cavtl.translations_uploads.find_each{|tl| tl.delete}
         #cavtl.translators.find_each { |tor| tor.delete}
         cavtl.cavs_tl_translators.find_each{ |cttl| cttl.delete}
         cavtl.developer_jobs.find_each{ |dj| dj.delete}
         cavtl.administrator_jobs.find_each{ |aj| aj.delete}
      end # transaction
  end # def
=begin
  @deprecated

  def self.check_en_keys_available_in_new_lang(cavs_translation_language_id)
    cavtl = CalmappVersionsTranslationLanguage.find(cavs_translation_language_id)
    cavtl.check_en_keys_available_in_new_lang
  end
=end  
  def check_en_keys_available_in_new_lang
    calmapp_version_id = calmapp_version_tl.id
    language_iso_code = translation_language.iso_code
    arr = Translation.translations_not_in_english(calmapp_version_id, language_iso_code)
    arr.each do |en_trans|
      Translation.create!(
        :dot_key_code => en_trans.dot_key_code,
        :translation => new_trans(en_trans),
        :cavs_translation_language_id => en. cavs_translation_language_id,
        :incomplete => true    
      )
    end   
  end
  
  def new_trans en_trans
    if en_trans.special_structure == "plural"
      translation = {}
      plurals = entrans.plurals
      plurals.keys.each{ |v|
        translation[plurals[v]] = nil 
      }
    elsif  en_trans.special_structure == "array7"
      translation = Array.new(7)
      
    elsif  en_trans.special_structure == "array13null"
      translation = Array.new(13)
    elsif en_trans.special_structure == "order_array"
       #arr = ActiveSupport::JSON.decode(en_trans.translation)
       #size = arr.length
       translation =  en_trans.translation
    elsif en_trans.special_structure == "hash"
       translation = {}
    elsif en_trans.special_structure == "array"
      translation = Array.new
    elsif  is_boolean(en_trans)
      translation = false
    else
      return nil     
    end       
  end
    
  def is_boolean en_trans
    val = ActiveSupport::JSON.decode(en_trans.translation)
    if val.is_a?(TrueClass) || val.is_a?(FalseClass)
      return true
    else
      return false
    end
  end 
  
  def database_for_translators_production_publishing
    return nil if calmapp_version_tl.production_redis_database.nil?
    prod = redis_database.find(calmapp_version_tl.production_redis_database)
    return prod
  end   
  
  def database_for_translators_test_publishing
    return nil if calmapp_version_tl.translators_redis_database.nil?
    test = redis_database.find(calmapp_version_tl.translators_redis_database)
    return test
  end  
  
end #class
