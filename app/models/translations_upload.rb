class TranslationsUpload < ActiveRecord::Base
  include Validations
  mount_uploader :yaml_upload, YamlTranslationFileUploader

  attr_accessor :duplicates_behavior
  belongs_to :calmapp_versions_translation_language, :foreign_key=>"cavs_translation_language_id"
  
  validates :description,  :presence=>true
  validate :upload_matches_translation_language_validation
  
  after_commit :do_after_commit, :on => :create
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
      data  = YAML.load_file(File.join(TranslationsUpload.uploaded_to_folder, yaml_upload.url))
  
      plurals= Hash.new
      key_value_pairs = TranslationsUpload.traverse_ruby(data, plurals, calmapp_versions_translation_language.calmapp_version_tl.id )
    rescue Psych::SyntaxError => pse
      #logger.error( yaml_upload_identifier() + " has produced the following error: " + pse + " Have a technical person check the syntax of the file")
  
      error =  PsychSyntaxErrorWrapper.new(pse, yaml_upload_identifier)
      puts error
      logger.error(error)
      
      raise error
    end  
    
    ret_val= 'ok' 
    begin
      Translation.transaction do
        puts yaml_upload.url
        t = BulkTranslations2.translations_to_db_from_file(key_value_pairs, id, calmapp_versions_translation_language, duplicates_behavior2)#, plurals)
        if t.errors.count > 0 then
          ret_val = t
          messages = ""           
          t.errors.full_messages.each { |msg| messages = messages + msg + " " }
          logger.error(messages)
         raise  UploadTranslationError.new(messages, yaml_upload_identifier)
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
#as it was on 28 June      
      if Translation.plural_hash? node
        
        store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals, true)
        
      else
    
        node.keys.each do |k|
          dot_key_stack.push(k)
          traverse_ruby(node[k], plurals, version_id, dot_key_stack, dot_key_values_map)    
        end
        dot_key_stack.pop
      end 
      
=begin
As it was on 2 Aug June  

       if dot_key_stack.length > 1 and dot_key_stack[0] == 'en' and Translation.plural_hash? node
        store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals, true)
      elsif dot_key_stack.length > 1 and dot_key_stack[0] != 'en' and Translation.dot_key_code_plural?(dot_key_stack[1..dot_key_stack.length-1].join('.'), version_id)  
        # we only store a dot key as a plural if the dot_key is an 'en' langauge
        store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals) 
      else
        node.keys.each do |k|
          dot_key_stack.push(k)
          traverse_ruby(node[k], plurals, version_id, dot_key_stack, dot_key_values_map)    
        end
        dot_key_stack.pop

      end  
=end
=begin 
 As it was on 8 Aug 
     
  
      plural = Translation.plural_hash? node
  
      if dot_key_stack.length > 1 and dot_key_stack[0] == 'en' and plural
        # we have an en plural
        store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals, true)
      elsif dot_key_stack.length > 1 and dot_key_stack[0] != 'en' and Translation.dot_key_code_plural?(dot_key_stack[1..dot_key_stack.length-1].join('.'), version_id)  
        # we only store a dot key as a plural if the dot_key is an 'en' langauge
        store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals, false) 
      if dot_key_stack.length > 1
        store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals, plural)
      else
        node.keys.each do |k|
          dot_key_stack.push(k)
          traverse_ruby(node[k], plurals, version_id, dot_key_stack, dot_key_values_map)    
        end
        dot_key_stack.pop
      end
=end    
    elsif node.is_a? Array then
      store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals)   
    elsif node.is_a? String then
      store_dot_key_value(dot_key_stack, node, dot_key_values_map, plurals)

    elsif (node.is_a? TrueClass ) || (node.is_a? FalseClass) then
      node = true if node.is_a? TrueClass
      node = false if node.is_a? FalseClass
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
=begin
  def start_background_process
    puts "sbp"
    ApplicationController.start_delayed_jobs_queue
  end
=end
=begin  
 
  
=begin
 Traverses the AST tree from the psych parser handler root, building a map of dot_keys and translations
 e.g. {"en.formtastic.labels.name" =>"Name", "en.formtastic.labels.dob"=>"Date of Birth"}
 from the yaml file parsed into a tree.
 Writes the dot_key and translation together with anchors and aliases to Translations objects and then to db.
 @param node takes a parser.handler.root in node
 @param dot_key_stack is an array of each partial key, removed as map etc is finished
 @param dot_key_values_map If given then this will provide a way of recreating the yaml file
 @param in_sequence is used as a boolean (=nil) and as a count of members of array
 @param container can be a map, array, however to initiate the recursive calls give a hash
 @param anchors Hash containing the keys and value for any anchors in the yaml file. Used for translating aliases.
 @param dot_key_values_map is a hash of dot_keys with values (including anchors and aliases)


 Note that in a translation file it is not possible to have a hash nested in an array (no dot_key possible), although this would be possible in yaml
 This method will not deal with that possibility
 Use like this
 > listener= Psych::TreeBuilder.new
 > parser   = Psych::Parser.new  listener
 > parser.parse File.new "test/fixtures/yaml_file_parsing/yaml_test.yml"                 # default.en.yml"                 #{}tree_print.yml"   #{}yaml_test.yml"          #{}
 > tree = parser.handler.root
 > container = Hash.new
 > dot_key_values_map = Hash.new
 > traverse language_id, tree, Array.new,  dot_key_values_map, container, nil
 > puts dot_key_values_map.to_s
=end

=begin
 @deprecated 
  def  traverse_yaml( node, dot_key_stack=Array.new, dot_key_values_map = nil,  container=Hash.new, anchors = Hash.new, in_sequence=nil )
    puts node.to_s
   
    scalar_content =false
    node.children.each { |child|
      
      if child.is_a? Psych::Nodes::Stream then
        map = Hash.new
        traverse_yaml( child, dot_key_stack, dot_key_values_map )
      elsif child.is_a? Psych::Nodes::Document then
        map = Hash.new
        puts child
        traverse_yaml(  child, dot_key_stack, dot_key_values_map, map, anchors, nil)
      elsif child.is_a? Psych::Nodes::Mapping then
        map= Hash.new
        scalar_content = false
        in_sequence = nil
        traverse_yaml( child, dot_key_stack, dot_key_values_map, map, anchors, in_sequence)
        if container.is_a? Hash then
          if dot_key_stack.length > 0 then
            key = dot_key_stack.pop
          else
            key= "document"
          end
          container.store(key, map)
        else
          raise Exception.new( "Error in parsing file. Trying to insert into " + container.class + ". Only Array and Map are allowed by Calm. Problem data is " + map.to_s)
        end
      elsif child.is_a? Psych::Nodes::Scalar then
        scalar_content = true if in_sequence
        unless scalar_content then
          dot_key_stack.push child.value
        end
        if scalar_content then
          dot_key = dot_key_stack.join "."
          if dot_key_values_map then
            dot_key_values_map.store(dot_key, ((scalar_content and child.anchor) ? ("&" + child.anchor + " ") : "") + child.value)
          end
          if child.anchor then
            anchors.store(child.anchor, child.value)
          end
          if container.is_a? Hash then
            # case of content into hash
            container.store(dot_key_stack.pop, child.value)
            write_translation_to_hash(  dot_key, child.value) #, true, child.anchor)
          end
        end unless in_sequence
        if container.is_a? Array then
          # case of sequence
          container.push child.value
          dot_key = dot_key_stack.join(".") << "." + format_leading_zeros( container.length-1)
          if dot_key_values_map then
            dot_key_values_map.store(dot_key, ((scalar_content and child.anchor) ? ("&" + child.anchor + " ") : "") + child.value)
          end
          if child.anchor then
            anchors.store(child.anchor, child.value)
          end
          if in_sequence then
            in_sequence =+ 1
          else
            in_sequence = 0
          end
        end
        scalar_content = !scalar_content unless in_sequence
      elsif child.is_a? Psych::Nodes::Alias
        if container.is_a? Array then
          # case of sequence
          container.push child.anchor
          dot_key = dot_key_stack.join(".") << "." + format_leading_zeros( container.length-1)
          if dot_key_values_map then
            dot_key_values_map.store(dot_key, "*" + child.anchor )
          end
          if in_sequence then
            in_sequence =+ 1
          else
            in_sequence = 0
          end
        else
          # must be a hash
          dot_key = dot_key_stack.join "."
          puts dot_key
          if dot_key_values_map then
            dot_key_values_map.store(dot_key, "*" + child.anchor)
          end
          container.store(dot_key_stack.pop, child.anchor)
          write_translation_to_hash(  dot_key, anchors[child.anchor]) #, false, child.anchor)
          scalar_content= false
        end
      elsif child.is_a? Psych::Nodes::Sequence
        dot_key = dot_key_stack.join "."
        array = Array.new
        in_sequence = 0
        traverse_yaml( child, dot_key_stack,  dot_key_values_map, array, anchors,  in_sequence)
        in_sequence =nil
        scalar_content=false
        container.store(dot_key_stack.pop, array)
        write_translation_to_hash(dot_key, array.to_s) #, false, child.anchor)
      else
        puts "Error!!! " + child.class  
      end
    }
    return container
  end
=end

=begin
 Call back to write the translations after a file is uploaded 
=end
  def do_after_commit
    
    #write_yaml_file_to_db()
    #DELAYED JOB
    Rails.logger.info "In TranslationsUpload.do_after_commit"
    Rails.logger.info "Self = " +  self.to_s
    Rails.logger.info "id = " + self.id.to_s
    TranslationsUploadWriteYamlJob.perform_later(id)
=begin #   
    Translation.check_translations_match_english2(
      #calmapp_versions_translation_language.calmapp_version_id, 
      #calmapp_versions_translation_language.translation_language.iso_code
      calmapp_versions_translation_language)
=end    
  end
  
  def self.write_yaml(id)
    tu = TranslationsUpload.find(id)
    if tu.nil?
      Rails.logger.info "Could not find translation upload with id : "  + id.to_s
    else
      Rails.logger.info "Found translation upload " + tu.to_s + " with id " + id.to_s        
    end 
    tu.write_yaml_file_to_db()
  end
=begin  
  def self.check_translations(id)
    cavtl = TranslationsUpload.find(id).calmapp_versions_translation_language
    Translation.check_translations_match_english2(cavtl)
  end
=end  
  
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