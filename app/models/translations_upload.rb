class TranslationsUpload < ActiveRecord::Base
  include Validations
  mount_uploader :yaml_upload, YamlTranslationFileUploader
  attr_accessible :description,  :cavs_translation_language_id, :yaml_upload, 
                  :calmapp_versions_translation_language, :duplicates_behavior, :written_to_db
  attr_accessor :duplicates_behavior
  belongs_to :calmapp_versions_translation_language, :foreign_key=>"cavs_translation_language_id"
  #belongs_to :calmapp_version
  
  #validates :translation_language_id,  :presence=>true
  #validates :translation_language_id, :existence => true
  
  #validates :calmapp_version_id,  :presence=>true
  #validates :calmapp_version_id, :existence => true
  
  validates :description,  :presence=>true
  validate :upload_matches_translation_language_validation
  after_create :write_file_to_db2
=begin
 Takes a yaml translation file, parses it, writes it as a tree and then converts the tree to a dot_key format
 @return a hash in dot_key => string_data format, suitable for writing to the db  
=end
  def write_file_to_db2 #overwrite  
    #binding.pry
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
    data  = YAML.load_file("public/" + yaml_upload.url)
    key_value_pairs = TranslationsUpload.traverse_ruby(data)
    #binding.pry
    rescue Psych::SyntaxError => pse
      raise PsychSyntaxErrorWrapper.new(pse, yaml_upload_identifier)
    end  
    ret_val= 'ok' 
    Translation.transaction do
      #binding.pry
      t = Translation.translations_to_db_from_file(key_value_pairs, id, calmapp_versions_translation_language, duplicates_behavior2)
      #binding.pry
      #base_error = t.errors[:base]
      if t.errors.count > 0 then
        #binding.pry
        ret_val = t
        # @todo error handling, logging here
        #raise ActiveRecord::Rollback
#=begin
        messages = ""
        binding.pry
        t.errors.full_messages.each { |msg| messages = messages + msg + " " } #each_full{  }
        #messages = messages + "Failed to write file : " + yaml_upload_identifier
        raise  UploadTranslationError.new(messages, yaml_upload_identifier)
#=end
      else
      # set  written to db here
      #binding.pry
         update_attributes(:written_to_db => true)
      end
    end # transaction
    return ret_val
  end
  
  def  self.traverse_ruby( node, dot_key_stack=Array.new, dot_key_values_map = Hash.new)#,  container=Hash.new, anchors = Hash.new, in_sequence=nil )
    #binding.pry
    if node.is_a? Hash then
      #puts "Hash"
      node.keys.each do |k|
        dot_key_stack.push(k)
        traverse_ruby(node[k], dot_key_stack, dot_key_values_map)    
      end
      dot_key_stack.pop 
      #puts dot_key_values_map
      #return
    elsif node.is_a? Array then
      # there should be no possibility of having hashes in arrays or arrays in arrays as there could not be a dot key system to manage this
      # so we assume that each element of an array is a scalar
      #puts "Array"
      #if node.to_s == 'order' then
        #binding.pry
      #end
      store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map) 
      #return    
    elsif node.is_a? String then
      #puts "String"
      store_dot_key_value(dot_key_stack, node, dot_key_values_map)
      #return
    elsif (node.is_a? TrueClass ) || (node.is_a? FalseClass) then
      #puts"Boolean"
      #puts node.to_s
      store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map)
      #return 
    elsif node.is_a? Integer then
       #puts "Integer"
       #puts node.to_s
       store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map)
       #return
    elsif node.is_a? Float then
       #puts "Float"
       #puts node.to_s
       store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map)
       #return
    elsif node.is_a? Symbol then
      #puts "Symbol"
      #puts node.to_s
      store_dot_key_value(dot_key_stack, node.to_s, dot_key_values_map)
      #return
    elsif node.nil? then
      puts "NIL"
      puts dot_key_stack
      store_dot_key_value(dot_key_stack, "", dot_key_values_map)  
    else
      puts "UNKNOWN CLASS " + node.class.name
    end
    return dot_key_values_map
  end
  
  def self.store_dot_key_value(dot_key_stack, node_str, dot_key_values)
    dot_key_values.store(dot_key_stack.join('.'), node_str)
    dot_key_stack.pop
  end
  
  def upload_matches_translation_language_validation
    #binding.pry
    #identifier_array  = yaml_upload.identifier.split(".")
    errors.add(:yaml_upload, I18n.t($MS + "translations_upload.yaml_upload." + "error.file_language_must_match_translation_language",:required_iso_code=>iso_code(), :chosen_file_iso_code=>iso_code_from_yaml_file_name())) unless iso_code_from_yaml_file_name() ==  iso_code()
    
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
    return yaml_upload.url.split('/').last
  end
=begin  
  @deprecated
  def write_file_to_db overwrite =false
    @data_hash = Hash.new
    file = File.new("public/" + yaml_upload.url)

    tree = parse_yaml_file file
    data = traverse_yaml( tree)
=begin
    @data_hash.keys.each do |k|
      if not overwrite then
        exists = Translation.where{dot_key_code==my{k}}.first
      end
      if not exists then
        trans = Translation.new :dot_key_code => k, :translation => @data_hash[k], :translations_upload_id => id,
                    :created_at => Time.now, :updated_at => Time.now
        if not trans.save! then
          puts "ERROR!!"
          puts trans.errors.messages
        end 
      end
      puts k
             
      
      
    end
 =end
#puts "tree"
#puts tree
#puts "data"
#puts data
    return @data_hash
  end 
=end

=begin  
  def parse_yaml_file file
    puts "start"
    listener = Psych::TreeBuilder.new
    parser   = Psych::Parser.new  listener
    parser.parse file
    tree = parser.handler.root
    #tree =nil
    #dot_key_values_map = Hash.new
    #dot_key_stack = Array.new
    #anchors= Hash.new
    #puts "before traverse"
    
    #return tree
    #return traverse_yaml( tree)  #, dot_key_stack,  Hash.new, dot_key_values_map,anchors, nil )

  end
=end  
  
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
  
  def write_translation_to_hash(key, translation ) #, translatable=true, anchor_or_alias=nil, tag=nil)
    #@redis.set(key, translation)
    @data_hash.store(key, translation)
  end
=end
  #puts "#{translation_language.iso_code}"
  #-----has_attached_file :yaml_upload, :styles => { :iso_code => 'en'}, :processors => [:parseyaml]#,# :styles => { :iso_code => translation_language.iso_code },
     #:url => "/uploads/upload/:id/:style/:basename.:extension",
     #:path => ":rails_root/public/uploads/uploads/:id/:basename.:extension"
     #:path => :path2
     #:path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename"
     #:path => :rails_root/public/system/:class/:attachment/:id_partition/:style/:filename
=begin
 !!! Gotcha 
 The validates statement below must come after the has_attached_file call
=end
  #x = lambda{|tu| tu.yaml_upload.original_filename}
  #x = lambda{|tu| tu.original_filename}
  #x = lambda{|yaml_upload| yaml_upload.original_filename}
  #-----validates_attachment :yaml_upload, :presence => true 
  #validates_attachment_content_type :yaml_upload, :content_type=>"application/x-yaml", :message=>  I18n.t($MS + "yaml_attachment_content_type.error", :yu=> ->(translations_upload){translations_upload.to_s})#lambda{|yaml_upload| yaml_upload.original_filename}) #x.call(yaml_upload)) 
  
  #----validate :validate_content_type 
=begin     def format_leading_zeros(num)
    return "%03d"  % num
  end
   def path2
     return Rails.root.to_s + '/public/system/' + self.class.name + '/yaml_upload/' + translation_language.iso_code + "/:filename"
   end
=end  

=begin
 I needed to do things this way rather than use the validates_attachment_content_type helper because 
   there was no way of including the name of the wrongly chosen file in the helper (that I could find!)
=end
=begin
  def validate_content_type
    if not ['application/x-yaml'].include?(self.yaml_upload_content_type)
      errors.add(:yaml_upload_file_name,  I18n.t($MS + "yaml_upload_content_type.error", :yu=> self.yaml_upload_file_name))
    end
  end
=end
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