#WHY this task
# The translator application, which is a separate project created by Mark, stores the work done by translators
# in a relational db. It publishes these translations to configured redis databases.
# In the developer environment it is recommended that a redis_db is setup as a slave of the local redis_db on the Translator app server.
# Once this is done, it syncs up all the translations.
# For Calm, we wanted backup yaml files of these translations, and we want them to stay up to date with changes that are made on the Translator app.
#HOW
# ensure your locales directory has all the translation files instantiated. i.e. if on the translator app there are
# translations for de, es, and en then make sure that you have the files something.es.yaml, something.en.yaml, something.de.yaml
# even if the files only contain the first key (es:)
# then run this task and enter the relative filepath for the english file (relative from config/locales) e.g. calm/calm.en.yml
# the task will then check all the translations are the same in the yaml file as on the redis db and prompt you to make choices if any are not the same
# the result is a ew yaml file will be printed in the tmp directory
# the task also does work on the other languages which you ask for via the prompts and similarly creates files in the tmp directory like es.yaml, de.yaml
# developer can then go and replace their real yaml files with these, but they should be checked first
# KNOWN ISSUE:
# for keys that have reserved words, this task will output "? \n" before the key and value, which apparently is valid yaml syntax, but Rubymine cannot format it and it looks strange
# so I usually simply remove these, there are ususally less than a dozen in a big file.
namespace :translator do

  desc "compare the translations in a yaml file with what is in a redis_db - Used for keeping backups of changes to translations in the Translator app. NOTE Please ensure your local redis_db is up to date with the lates translations on the Translator application."

  task :compare => :environment do
    keep_going = true
    while keep_going
      other_languages = ['de','es','fr', 'lt']
      other_language_file_paths = {}
      file_found = false
      # file_path = nil
      while !file_found
        puts "Enter the name of the english translations file you would like to compare including relative directory to config/locales/, e.g. 'calm/calm.en.yml' "
        trans_file_name = $stdin.gets.chomp
        unless trans_file_name.index("en.")
          file_found = false
          puts "please enter the english translation file and we will take care of the corresponding other translations"
        else
          file_path = File.join(Rails.root, "config", 'locales', trans_file_name)
          if File.exist?(file_path)
            puts "file found"
            file_found = true
          else
            puts "That file does not exist, please try again."
          end
        end
      end
      puts "please enter the iso codes of the other languages you would like to backup separated by commas, e.g. 'es,lt' or type 'default' to select the default '#{other_languages.join(",")}' (enter nothing to only do en) "
      other_langs_inp = $stdin.gets.chomp()
      if !other_langs_inp.downcase.in?(['default', 'defalt', 'defualt'])
        other_languages = other_langs_inp.gsub(" ", "").split(",")
      end
      if other_languages.any?
        other_languages.each do |iso_code|
          other_lang_file_path = file_path.sub("en.", "#{iso_code}.")
          if File.exist?(other_lang_file_path)
            other_language_file_paths[iso_code] = other_lang_file_path
            puts "Found other language file #{other_lang_file_path}"
          else
            puts "Could not find other language file #{other_lang_file_path} so will not work for #{iso_code}"
          end
        end
      end
      sleep(2) # allow user time to read messages
      processor= TranslationYamlRedisProcessor.new translation_file_path: file_path, other_language_file_paths: other_language_file_paths
      puts processor.compare_and_create_new_yaml_file
      keep_going = prompt_continue "would you like to try again? y/n"
    end

  end
  # File.read(file_path)
  def prompt_continue message = "Continue? y/n"
    puts message
    cont = $stdin.gets().chomp()
    if cont.downcase.in?(["n","no"])
      return false
    else
      return true
    end
  end

  class TranslationYamlRedisProcessor
    require 'ya2yaml' # standard Hash.to_yaml des not work in many cases esp special chars and even apostrophes
    #so use .ya2yaml(:syck_compatible => true)
    attr_reader :translations_hash_from_yaml
    def initialize translation_file_path:, other_language_file_paths:, redis_db_instance:0, redis_db_password: Rails.application.secrets[:redis_local_pw]
      @redis_db = Redis.new(db: redis_db_instance, password: redis_db_password)
      @translations_hash_from_yaml = YAML.load_file(translation_file_path)
      @other_language_translations_hashes = {}
      @dot_key_stack_array = [] # used as a working array for processing the @translations_hash_from_yaml
      @translations_map_array = [] # e.g. [['en.lookups.go', "Go"], ['en.lookups.stop',"Stop"]]
      @other_languages_translations_maps = {} # e.g. [['en.lookups.go', "Go"], ['en.lookups.stop',"Stop"]]
      @new_translations_map_array = [] # e.g. [['en.lookups.go', "Go"], ['en.lookups.stop',"Stop"]]
      other_language_file_paths.each do |iso_code, file_path|
        @other_language_translations_hashes[iso_code] = YAML.load_file(file_path)
        @other_languages_translations_maps[iso_code] = [] #initialize to empty array
      end

    end
    # iterate through the yaml file and compare each translation to the translation stored on the redis db
    # users are prompted which value they wish to keep when there are differences
    # result is that a new yaml file iscreated and written to file at param relative_file_path
    def compare_and_create_new_yaml_file relative_write_file_path: "tmp/translation_yaml_processor_result#{Time.now.to_i}.yaml"
      populate_translations_map
      compare_with_redis #to populate new translations map
      new_translations_hash = calculate_new_translations_hash
      write_hash_to_yaml_file new_translations_hash, relative_write_file_path
      compare_other_languages_with_redis
      @other_languages_translations_maps.each do |iso_code, trans_array|
        new_trans_hash = calculate_new_translations_hash translations_map_array: trans_array
        write_hash_to_yaml_file new_trans_hash, relative_write_file_path.sub(".yaml", ".#{iso_code}.yaml")
      end
    end
    private
      #recursive method that populates the instance variable @translations_map_array via the store_key_value_in_map method
      def populate_translations_map node = @translations_hash_from_yaml
        if node.is_a? Hash then
          if is_plural_hash? node
            store_key_value_in_map(node, true)
          else
            node.keys.each do |k|
              @dot_key_stack_array.push(k)
              puts "#{@dot_key_stack_array}"
              populate_translations_map(node[k])
            end
            @dot_key_stack_array.pop
          end
        elsif node.is_a? Array then
          store_key_value_in_map(node.to_json)
        elsif node.is_a? String then
          store_key_value_in_map(node)
        elsif node.in?([true, 'true', false, 'false'])
          node = true if node.is_a? TrueClass || node == "true"
          node = false if node.is_a? FalseClass || node == "false"
          store_key_value_in_map(node)
        elsif node.is_a? Integer then
          store_key_value_in_map(node.to_s)
        elsif node.is_a? Float then
          store_key_value_in_map(node.to_s)
        elsif node.is_a? Symbol then
          store_key_value_in_map(node.to_s)
        elsif node.nil? then
          puts "NIL"
          puts @dot_key_stack_array
          store_key_value_in_map("")
        else
          raise "Reached a node whose value is an unknown class dot_key_code: #{dot_key_stack} this should not occur, class is #{node.class.name} "
        end
      end
      # go through the @translations_map_array (which will be empty unless the populate_translations_map method has been called beforehand)
      # and lookup corresponding values on redis, if they are dfferent ask the user which they wuld prefer to keep
      # populate the @new_translations_map_array based on the user answers
      def compare_with_redis
        total_trans = @translations_map_array.count
        puts "now going through #{total_trans} translations and commparing with what is in the redis db ..."
        @translations_map_array.each_with_index do |ar, index|
          dot_key_code = ar[0]
          value = ar[1]
          rvalue = @redis_db.get(dot_key_code)
          redis_value = rvalue.present? ? ActiveSupport::JSON.decode(rvalue) : nil
          new_val = user_chooses(dot_key_code: dot_key_code, yaml_value: value, redis_value: redis_value)
          @new_translations_map_array<< [dot_key_code, new_val] if new_val.present?
        end
      end
      #user has to choose which value to use, @param accept_redis_if_no_yaml especially useful for other languages so one does not need to give continual input for new translations
      def user_chooses(dot_key_code:, yaml_value:, redis_value:, accept_redis_if_no_yaml: false)
        puts "#{dot_key_code}: #{yaml_value || redis_value}  #{ redis_value == yaml_value}"
        keep_trans_code = 1
        choice = nil
        if redis_value.present? && redis_value != yaml_value
          if yaml_value.nil? && accept_redis_if_no_yaml
            keep_trans_code = 2
          else
            puts "the values are different in the yaml file and the redis db for #{dot_key_code}"
            puts "type 1 if you would like to keep the yaml file value: '#{yaml_value}'"
            puts "type 2 if you would like to keep the redis db value:  '#{redis_value}'"
            keep_trans_code = $stdin.gets.chomp()
            while !keep_trans_code.in?(["1", 1, "2", 2])
              puts "#{keep_trans_code} not a valid option, please enter either 1 or 2"
              keep_trans_code = $stdin.gets.chomp()
            end
            keep_trans_code = keep_trans_code.to_i
          end
        elsif redis_value.nil? && yaml_value.present?
          # maybe the translation was removed from the redis db for a reason so give user an option to remove the translation from the new yaml file
          puts "the value for redis is nil for #{dot_key_code} and it is #{yaml_value} in the yaml file"
          puts "type 1 to keep the yaml file entry (recommended)"
          puts "type 3 to remove this entry (i.e. this translation is no longer needed)"
          keep_trans_code = $stdin.gets.chomp()
          while !keep_trans_code.in?(["1", 1, "3", 3])
            puts "#{keep_trans_code} not a valid option, please enter either 1 or 3"
            keep_trans_code = $stdin.gets.chomp()
          end
          keep_trans_code = keep_trans_code.to_i
        end
        if redis_value == yaml_value
          puts "the value is the same on the yaml file as in the redis db"
          choice = yaml_value
        else
          if keep_trans_code == 2
            puts "2: you have chosen to keep the value from the redis db: #{redis_value}"
            choice = redis_value
          elsif keep_trans_code == 1
            puts "1: you have chosen to keep the value from the yaml file: #{yaml_value}"
            choice = yaml_value
          elsif keep_trans_code == 3
            choice = nil
          end
        end
        choice
      end
      def compare_other_languages_with_redis
        # use the English translation map because en is default and our yaml files for other languages are incomplete but the redis_db may be more complete for these languages
        @other_language_translations_hashes.each do |iso_code, trans_hash|
          puts "Now comparing and updating for #{iso_code} using en as default"
          @translations_map_array.each do |ar|
            key = ar[0]
            lang_key = key.sub("en.", "#{iso_code}.")# en.lookups.go => fr.lookups.go
            rvalue = @redis_db.get(lang_key)
            if rvalue.present?
              redis_value = ActiveSupport::JSON.decode(rvalue)
              yaml_value = lookup_hash_with_dot_key_code lang_key, trans_hash
              chosen_val = user_chooses(dot_key_code: lang_key, yaml_value: yaml_value, redis_value: redis_value, accept_redis_if_no_yaml: true)
              @other_languages_translations_maps[iso_code] << [lang_key, chosen_val] if chosen_val.present?
            end
          end
        end
      end
      def calculate_new_translations_hash translations_map_array: @new_translations_map_array
        new_translations_hash = {}
        # create a hash from the translations_map_array
        translations_map_array.each do |ar|
          key = ar[0] # e.g. en.lookups.go
          value = ar[1] # e.g. "Go"
          keys = key.split(".")
          working_hash = new_translations_hash
          keys.size.times do |i|
            k = keys[i]
            working_hash[k] = {} if working_hash[k].nil?
            if i == (keys.size - 1)
              working_hash[k] = value
            else
              next_step = working_hash[k]
              working_hash = next_step
            end
          end
        end
        return new_translations_hash
      end

      def write_hash_to_yaml_file a_hash, a_relative_path
        puts "saving the new translations file to relative path #{a_relative_path}"
        File.write(a_relative_path, a_hash.ya2yaml(:syck_compatible => true)) # standard Hash.to_yaml des not work in many cases esp special chars and even apostrophes
      end
      def lookup_hash_with_dot_key_code dot_key_code, trans_hash
        keys = dot_key_code.split(".")
        working_hash = trans_hash
        keys.size.times do |i|
          k = keys[i]
          if working_hash[k].present?
            if i == (keys.size - 1)
              return working_hash[k]
            else
              next_step = working_hash[k]
              working_hash = next_step
            end
          else
            return nil
          end
        end
      end
      def is_plural_hash? hash
        plural_keys = %w(zero one two few many other)
        keys = hash.keys
        if keys.empty?
          return false
        end
        keys.each{|k|
          if not plural_keys.include?(k) then
            return false
          end
        }
        return true
      end

      def store_key_value_in_map value, is_plural= false
        dot_key_code = @dot_key_stack_array.join('.')
        @translations_map_array << [dot_key_code, value]
        @dot_key_stack_array.pop
      end

  end

end

