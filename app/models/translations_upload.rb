class TranslationsUpload < ActiveRecord::Base
  include Validations
  mount_uploader :yaml_upload, YamlTranslationFileUploader

  attr_accessor :duplicates_behavior
  belongs_to :calmapp_versions_translation_language, :foreign_key=>"cavs_translation_language_id"
  
  validates :description,  :presence=>true
  validate :upload_matches_translation_language_validation
  #after_create :do_after_create
  after_create :do_after_create#, :on => :create
  
  before_destroy :do_before_destroy
  
  def self.base_locales_folder
    File.join(Rails.root, "base_locales")
  end 
  
  def self.uploaded_to_folder
    return "public"
  end   
=begin
 Takes a yaml translation file, parses it, writes it as a tree and then converts the tree to a dot_key format
 @return a hash in dot_key => string_data format, suitable for writing to the db  
=end
  
  def write_yaml_file_to_db #overwrite  
    if duplicates_behavior == "overwrite"
        duplicates_behavior2 =   Translation.Overwrite[:all]
    elsif duplicates_behavior ==  "skip" 
        duplicates_behavior2 = Translation.Overwrite[:continue_unless_blank]
    elsif duplicates_behavior == "cancel"
      duplicates_behavior2 = Translation.Overwrite[:cancel]
    else
      duplicates_behavior2 = Translation.Overwrite[:continue_unless_blank]
    end     
    begin
=begin      
      path = Rails.root
      Rails.logger.info path + " " + Dir.entries(path).to_s
      path = File.join(Rails.root, TranslationsUpload.uploaded_to_folder) 
      Rails.logger.info path + " " + Dir.entries(path).to_s
      arr = yaml_upload.url.split("/")
      arr.each { |dir| 
        path = File.join(path, dir)
        if ! Dir.exist?(path)
          if !File.exist?(path)
            Rails.logger.info(path + " does not exist. Big Problem for writing upload.")  
          else
            Rails.logger.info(path + " does exist" )  
          end
        else 
          Rails.logger.info path + " " + Dir.entries(path).to_s 
        end
        
        }
=end       
      #File.join(Rails.root.to_path, TranslationsUpload.uploaded_to_folder,yaml_upload.url )
      #Rails.logger.info Rails.root.to_path
      #Rails.logger.info TranslationsUpload.uploaded_to_folder
      #Rails.logger.info yaml_upload.url
      path = File.join(Rails.root.to_path, TranslationsUpload.uploaded_to_folder, yaml_upload.url)
      Rails.logger.info path
      Rails.logger.info("Trying to open: " + File.exist?(path).to_s )
      data  = YAML.load_file(File.join(Rails.root.to_path, TranslationsUpload.uploaded_to_folder, yaml_upload.url))
      plurals= Hash.new
      key_value_pairs = TranslationsUpload.traverse_ruby(data, plurals, calmapp_versions_translation_language.calmapp_version_tl.id )
      #binding.pry
    rescue Psych::SyntaxError => pse
      error =  PsychSyntaxErrorWrapper.new(pse, yaml_upload_identifier)
      puts error
      logger.error(error)
      
      raise error
    end  
    
    ret_val= 'ok' 
    begin
      Translation.transaction do
        puts yaml_upload.url
        #binding.pry if key_value_pairs.keys.include?("restrict_dependent_destroy")
        t = BulkTranslations2.translations_to_db_from_file(key_value_pairs, id, calmapp_versions_translation_language, duplicates_behavior2)#, plurals)
        if t.errors.count > 0 then
          ret_val = t
          messages = ""           
          t.errors.full_messages.each { |msg| messages = messages + msg + " " }
          logger.error(messages)
          if not messages.include? "Dot key Code does not exist"
            raise  UploadTranslationError.new(messages, yaml_upload_identifier)
          end  
        end #errors.count
      end #trans 
      rescue UploadTranslationError => error
        msg = "Error while writing " + error.file_name + " message: " + error.message + " No translations written to database"
        puts msg
        Rails.logger.error(msg)
        raise
        
       rescue StandardError => error
         msg =  "Error while writing " + yaml_upload_identifier + " message: " + error.message + " No translations written to database"
         puts msg
         
         Rails.logger.error(msg)
         
         raise     
       end#  outside block rescues
    
    # end #begin before trans
    
    return ret_val
  end #def

=begin
 @param node contains the current node to be written or traversed according to type
 @param plurals contains the current list of plurals for this file
       This should be changed to the list of english plurals if the language is other than english
 @param version_id id of the version which is being uploaded to.      
 @param dot_key_stack contains the current dot_key separated into an array, first element the language iso_code
        eg ["en", "datetime", "distance_in_words"]
 @param dot_key_values_map contains aall the dot_keys and translations for this file in a hash      
=end  
  def  self.traverse_ruby( node, plurals, version_id, dot_key_stack=Array.new, dot_key_values_map = Hash.new)#,  container=Hash.new, anchors = Hash.new, in_sequence=nil )     

    if node.is_a? Hash then     
      if Translation.plural_hash? node
        store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals, true)
      else
    
        node.keys.each do |k|
          dot_key_stack.push(k)
          traverse_ruby(node[k], plurals, version_id, dot_key_stack, dot_key_values_map)    
        end
        dot_key_stack.pop
      end    
    elsif node.is_a? Array then
      store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals)   
    elsif node.is_a? String then
      store_dot_key_value(dot_key_stack, node, dot_key_values_map, plurals)

    elsif (node.is_a? TrueClass ) || (node.is_a? FalseClass) || node == "true" || node == "false" then
      #binding.pry
      node = true if node.is_a? TrueClass || node == "true"
      node = false if node.is_a? FalseClass || node == "false"
      #store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map, plurals)
      store_dot_key_value(dot_key_stack, node, dot_key_values_map, plurals)
    elsif node.is_a? Integer then
       store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map, plurals)
    elsif node.is_a? Float then
       store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map, plurals)
    elsif node.is_a? Symbol then
      store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map, plurals)
    elsif node.nil? then
      puts "NIL"
      puts dot_key_stack
      store_dot_key_value(dot_key_stack, "", dot_key_values_map, plurals)  
    else
      puts "UNKNOWN CLASS " + node.class.name
    end
    #binding.pry
    return dot_key_values_map
  end
  # @param plurals is a hash where the keys are dot_key_codes.
  # store_dot_key_values stores the dot_key with the node as value
  # but also stores the dot_key in plurals with the value of @param plural
  # This plurals will be used when writing the translation to the db to make sure that the plural is properly formated
  def self.store_dot_key_value(dot_key_stack, node_str, dot_key_values, plurals, plural=false)
    key = dot_key_stack.join('.')
    dot_key_values.store(key, node_str)
    plurals.store(key, plural)
    dot_key_stack.pop
  end
  
  def upload_matches_translation_language_validation
    
    #identifier_array  = yaml_upload.identifier.split(".")
    errors.add(:yaml_upload, 
       I18n.t($MS + "translations_upload.yaml_upload." + "error.file_language_must_match_translation_language",
                 :required_iso_code=>iso_code()
              )
       )unless iso_code_from_yaml_file_name() ==  iso_code()
  end
  
  def iso_code_from_yaml_file_name
    
    identifier_array  = yaml_upload_identifier.split(".")
    return identifier_array[identifier_array.length-2]
  end 
  

   
  def iso_code    
    return calmapp_versions_translation_language.translation_language.iso_code 
  end   
  #  documentation says the should get this with yaml_upload.indentifier. It quite often returns nil
  # So we work around
  def yaml_upload_identifier
    #return '*.yml' if yaml_upload.url == default_url
    return yaml_upload.url.split('/').last
  end

  
  def do_before_destroy
    #"This does not work when you go through the calmapp_versions_translation_language_controller.   So it is also done in the controller! Apparently Cocoon does a delete rather than destroy!!"
    puts "Before delete uploader : removing file"
    remove_yaml_upload!
  end
=begin
 Call back to write the translations after a file is uploaded 
=end
  def do_after_create
    Rails.logger.info "In TranslationsUpload.do_after_save"
    Rails.logger.info "Self = " +  self.to_s
    Rails.logger.info "id = " + self.id.to_s
    #Rails.logger.error "1. do_after_commit  rrr " + Rails.root.to_path
    if Rails.env.development? || Rails.env.test?
      #Needs time to finish uploading file
      TranslationsUploadWriteYamlJob.perform_later(id) 
    else  
      TranslationsUploadWriteYamlJob.perform_later(id)  
    end
    
=begin #   
    Translation.check_translations_match_english2(
      #calmapp_versions_translation_language.calmapp_version_id, 
      #calmapp_versions_translation_language.translation_language.iso_code
      calmapp_versions_translation_language)
=end    
  end
  
  def self.write_yaml(id)
    Logger.new("log/upload.log").info "3. self.write_yaml rrr " + Rails.root.to_path
    tu = TranslationsUpload.find(id)
    if tu.nil?
      Logger.new("log/upload.log").info "Could not find translation upload with id : "  + id.to_s
    else
      Logger.new("log/upload.log").info "Found translation upload " + tu.to_s + " with id " + id.to_s        
    end 
    tu.write_yaml_file_to_db()
  end
 
  
=begin
 Adds Czech to Calmapp version. (Works via callbacks in calmapp_version) 
=end
  def self.demo     
      version = CalmappVersion.joins{calmapp}.where{calmapp.name =~ 'calm%'}.where{version == 4}.first     
      cs = TranslationLanguage.where{iso_code == 'cs'}.first
      #this will also upload cs.yml
      version.translation_languages << cs
      fr = TranslationLanguage.where{iso_code == 'fr'}.first
      #This will also upload fr.yml
      
      version.translation_languages << fr
  end
=begin
  formats an integer to have at least 3 digits 
=end  
  def format_leading_zeros(num)
    return "%03d"  % num
  end
  
  def yaml_to_array yaml
    yaml.tr('[','').tr(']','').split(',')
  end
end

class UploadTranslationError < StandardError
  attr_accessor :file_name
  
  def initialize(message, file_name_param)
    super message
    @file_name = file_name_param
  end
end

class PsychSyntaxErrorWrapper < StandardError
  attr_accessor :file_name
  def initialize(psych_syntax_error, file_name_param)
    if psych_syntax_error.message.include?("):") then
      msg = psych_syntax_error.message.split('):')[1]
    else
      msg = psych_syntax_error
    end
    super msg
    @file_name = file_name_param
  end
end