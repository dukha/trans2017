class TranslationsUpload < ActiveRecord::Base
  include Validations
  mount_uploader :yaml_upload, YamlTranslationFileUploader

  attr_accessor :duplicates_behavior
  belongs_to :calmapp_versions_translation_language, :foreign_key=>"cavs_translation_language_id"
  
  validates :description,  :presence=>true
  validate :upload_matches_translation_language_validation
  #after_create :write_file_to_db2#, :on => :create
  after_commit :do_after_commit, :on => :create
  def self.base_locales_folder
    File.join(Rails.root, "base_locales")
  end 
  
  def self.uploaded_to_folder
    return "public/"
  end   
=begin
 Takes a yaml translation file, parses it, writes it as a tree and then converts the tree to a dot_key format
 @return a hash in dot_key => string_data format, suitable for writing to the db  
=end
  def write_yaml_file_to_db #overwrite  
    
    puts "db2"
    puts CalmappVersion.find(calmapp_versions_translation_language.calmapp_version_id).description
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
      data  = YAML.load_file(TranslationsUpload.uploaded_to_folder + yaml_upload.url)
      #binding.pry
      plurals= Hash.new
      key_value_pairs = TranslationsUpload.traverse_ruby(data, plurals )
    rescue Psych::SyntaxError => pse
      #logger.error( yaml_upload_identifier() + " has produced the following error: " + pse + " Have a technical person check the syntax of the file")
      #binding.pry
      error =  PsychSyntaxErrorWrapper.new(pse, yaml_upload_identifier)
      puts error
      logger.error(error)
      
      raise error
    end  
    
    ret_val= 'ok' 
    begin
      Translation.transaction do
        
        puts yaml_upload.url
        #puts calmapp_versions_translation_language.id
        
        
        t = BulkTranslations.translations_to_db_from_file(key_value_pairs, id, calmapp_versions_translation_language, duplicates_behavior2, plurals)
          #if t.nil? then
            
          #end #nil
          
          
          #update_attributes(:written_to_db => true)
          #base_error = t.errors[:base]
          
          if t.errors.count > 0 then
            
            ret_val = t
            # @todo error handling, logging here
            #raise ActiveRecord::Rollback
    #=begin
            messages = ""
            
            t.errors.full_messages.each { |msg| messages = messages + msg + " " } #each_full{  }
            #messages = messages + "Failed to write file : " + yaml_upload_identifier
            logger.error(messages)
           raise  UploadTranslationError.new(messages, yaml_upload_identifier)
    #=end
          else
          # set  written to db here
          
  #           update_attributes(:written_to_db => true)
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
  
  #handle_asynchronously :write_file_to_db2
  def  self.traverse_ruby( node, plurals, dot_key_stack=Array.new, dot_key_values_map = Hash.new)#,  container=Hash.new, anchors = Hash.new, in_sequence=nil )
    #if dot_key_stack.include? 'less_than_x_minutes' then
      
    #end      
    if node.is_a? Hash then
      #puts "Hash"
      #if node.keys.include? :zero then
        
      #end
      if plural_hash? node
        
        store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals, true)
        
      else
        node.keys.each do |k|
          dot_key_stack.push(k)
          traverse_ruby(node[k], plurals, dot_key_stack, dot_key_values_map)    
        end
        dot_key_stack.pop
      end 

      
    elsif node.is_a? Array then
      # there should be no possibility of having hashes in arrays or arrays in arrays as there could not be a dot key system to manage this
      # so we assume that each element of an array is a scalar
      
      # This needs to be broadened out to any array which contains symbols
      #if node.to_s.include? ":year" then #node.to_s == 'order' #&& dot_key_stack.last = "datetime" then
        # In this case the array values are symbols. Symbols don't parse in json!!
        # we get rid of symbols when writing to  the db
        
        #node.each_index{ |index| node[index] = node[index].inspect}
        
      #end
      store_dot_key_value(dot_key_stack, node.to_json, dot_key_values_map, plurals) 
      #return    
    elsif node.is_a? String then
      #puts "String
    
      store_dot_key_value(dot_key_stack, node, dot_key_values_map, plurals)
      #return
    elsif (node.is_a? TrueClass ) || (node.is_a? FalseClass) then
      #puts"Boolean"
      #puts node.to_s
      store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map, plurals)
      #return 
    elsif node.is_a? Integer then
       #puts "Integer"
       #puts node.to_s
       store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map, plurals)
       #return
    elsif node.is_a? Float then
       #puts "Float"
       #puts node.to_s
       store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map, plurals)
       #return
    elsif node.is_a? Symbol then
      #puts "Symbol"
      #puts node.to_s
      store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map, plurals)
      #return
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
    #if node_str.is_a? String
      
    #end
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
  
  def self.plural_hash? node
    
    if node.is_a? Hash then
      keys = node.keys
      if keys.empty?
        return false
      end
      keys.each{|k|
        #if node[k] == "about_x_months"  
          
        #end
        if not CldrType.PLURALS.include?(k) then
          return false
        end 
      }
      return true
    else
      return false
    end  
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
    
    write_yaml_file_to_db()
#    ApplicationController.start_delayed_jobs_queue
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