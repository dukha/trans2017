class Translation < ActiveRecord::Base
  # needed for self.search
  extend SearchModel
  include SearchModel
  
  belongs_to :calmapp_versions_translation_language, :foreign_key => "cavs_translation_language_id"
  belongs_to :translations_upload
  
  
  validates :dot_key_code, :uniqueness=>{:scope=> :cavs_translation_language_id},  :presence=>true 
  validates :cavs_translation_language_id, :presence => true #:calmapp_versions_translation_language, :presence => true
  validate :translation,  :valid_json
  validate :translation, :interpolations_correct
  
  before_validation :do_before_validation#, :if => "not language_en?"
  #before_save :ensure_translation_valid_json
  after_create :add_other_language_records_to_version, :if => :language_en? #Proc.new { |translation| translation.language.iso_code=='en'}
  after_destroy :delete_similar_dot_keys_not_english, :if => :language_en? # => Proc.new { |translation| translation.language.iso_code=='en'}
  
  attr_accessor  :english, :criterion_iso_code, :criterion_cav_id, :criterion_cavtl_id, :written#, :selection_mode 
  
  TRANS_PLURAL = "plural"
  TRANS_ARRAY_13_NULL = "array13null"
  TRANS_ARRAY_7 = "array7"
  TRANS_ORDER_ARRAY = "order_array"
  TRANS_HASH = "hash"
  #@@selection_mode
  
  def self.selection_mode mode
    @@selection = mode
  end
  def self.selection_mode
    @@selection_mode
  end
  
  
  def self.searchable_attr
    %w(iso_code dot_key_code cav_id translation updated_at special_structure cavtl_id)
  end
  
  def self.sortable_attr
    %w(dot_key_code translation translation special_structure)
  end
  
  def do_before_validation
      mark_english_special_structures()
     if language.iso_code != "en"
       convert_empty_strings_to_hash_and_array_templates()  
     end
     ensure_translation_valid_json
  end
  
  def mark_english_special_structures
    #if language.iso_code == "en" then
      if special_structure.nil?
        if JSON.is_json?(translation)
          trans = ActiveSupport::JSON.decode(translation)
          #
        else
          trans = translation
        end  #is json
        if trans.is_a? Hash
          if Translation.is_plural_hash? trans then
            if language.iso_code == "en" then
              self.special_structure = Translation::TRANS_PLURAL
            end
            self.incomplete = (Translation.is_plural_hash_complete?(trans))
          else
            # do nothing  
          end #plural hash
        elsif trans.is_a? Array
          self.incomplete = (Translation.is_array_complete?(trans))
          if dot_key_code.end_with?("month_names") then
            if language.iso_code == "en" then
              self.special_structure = TRANS_ARRAY_13_NULL
            end
          elsif dot_key_code.end_with?("day_names")  
            if language.iso_code == "en" then  
              self.special_structure = TRANS_ARRAY_7
            end
           elsif dot_key_code.include?("date.order")
             if language.iso_code == "en" then
              self.special_structure = TRANS_ORDER_ARRAY
             end
          end #use dot key to figure it out
        else
          #dp nothing not dealing with other types.
        end # hash array 
      else
        #do nothing if specail struct already has value
      end  #special structure      
    #end #lang en
    
  end
  
  def self.is_plural_hash_complete? hash
    #keys = hash.keys
    incomplete = true
    hash.each{ |k,v|
      if hash[k].blank? && incomplete then
        incomplete = false
      end
      }
    return incomplete  
  end
  
  def self.is_array_complete? array
    #keys = hash.keys
    incomplete = true
    array.each{ |e|
      if e.blank? && incomplete then
        incomplete = false
      end
      }
    return incomplete  
  end
=begin
 Validation 
=end
  def valid_json
    if not JSON.is_json? translation
      errors.add(:translation, "must be json")  
    end
  end
=begin
 Validation 
 Compares number of interpolations in translation with those in english. translations must be <= english
=end  
  def interpolations_correct
    #binding.pry
    trans  = translation #ActiveSupport::JSON.decode(translation)
    en = english_translation_object().translation
    regex = /%{\w{1,}}/
    en_interpolations =  en.scan(regex)
    en_interpolations.uniq!
    trans_interpolations = trans.scan(regex)
    trans_interpolations.uniq!
    #errors = []
    #warnings = []
    pre_supplied_by_ar = ["%{model}", "%{count}", "%{attribute}", "%{value}"]
    reserved_interpolations = ["%{default}", "%{scope}"] # should not be in any messge
    if en_interpolations.count < trans_interpolations.count then
      trans_interpolations.each do |ti|
        if not pre_supplied_by_ar.include?(ti)
          if not en_interpolations.include?(ti)
            #despite this it throws a StandardError: handled in controller
            errors.add( "'" + ti + "' is not in the English. Any substitution must be spelled exactly the same as in English. Don't put uppercase(capital) letters for lowercase letters. If you substitution is not in English then remove it. Otherwise correct the spelling.")
          end # error  
        end #not pre supplied  
      end # do
    #elsif en_interpolations.count > trans_interpolations.count then
      #errors.add("You have not used all the substitutions from English. Your translation may be clearer if you use them all.")
    end # if compare   
  end
  
  def convert_empty_strings_to_hash_and_array_templates
    self.incomplete = nil
     en_trans = english_translation_object
   # because we only put in dot_key_codes, no translations at this point   
   if self.translation.blank? then
     if en_trans.is_plural?
       self.incomplete = true 
       self.translation = Translation.create_json_plural_template(language.plurals) 
     elsif en_trans.is_array13null?  
       self.incomplete = true
       self.translation = Translation.create_json_array_template 13, true 
     elsif en_trans.is_array7?  
       self.incomplete = true
       self.translation = Translation.create_json_array_template 7, false
     elsif en_trans.is_order_array?   
       self.incomplete = true
      
       self.translation = en_trans.translation
       if not JSON.is_json?(translation) then
         self.translation = ActiveSupport::JSON.encode(translation)
       end
     end
   end  
  end
  def english_translation_object
    return self if language.iso_code == 'en'
    dkc= self.dot_key_code
    #cav_id = calmapp_version().id
    #t = joins{:calmapp_versions_translation_language}.where{dot_key_code == dkc}.where{calmapp_version_id == cav_id}.first
    t = english_translations.where{dot_key_code == my{dkc}}.first
    return t
  end
=begin
 Get translations with version and languages 
#=end  
 scope :versions_and_languages, -> {
    joins{calmapp_versions_translation_language.calmapp_version.translation_language}.
    joins(:calmapp_version).
    joins(:translation_language)
    #language  = translation_language_from_param(language)
    #join_to_cavs_tls_arr(calmapp_version_id).
    #joins_to_tl_arr.
  }
=end  
=begin
  @return ActiveRecord::Relation of English translations for the same version of this translation   
=end  
  def english_translations 
    cav_id =  calmapp_versions_translation_language.calmapp_version_id
    cavtl_en =  CalmappVersionsTranslationLanguage.
           where{ calmapp_version_id == cav_id }.
           where{ translation_language_id == TranslationLanguage.TL_EN.id}.first
    return Translation.joins{calmapp_versions_translation_language.translation_language}. 
           where{calmapp_versions_translation_languages.id == cavtl_en.id}.
           select("translations.id, dot_key_code, translation_languages.iso_code, cavs_translation_language_id, special_structure, translation")      
  end

  def self.Overwrite
    # :all means all existing translations that are matched will be overwritten( except if the same as new)
    # :continue_unless_blank means that no existing translations(by language and dot_code_key) will be overwritten unless translation is null
    # :cancel means an the writing of a file will be rolled back if a duplicate language and key is found( where translation is not null )
    {:all=>"OVERWRITE_ALL", :continue_unless_blank=>"OVERWRITE_CONTINUE", :cancel => "CANCEL_OPERATION"}
  end
  
=begin
 @return prepend iso_code to dot_key_code  
=end  
  def full_dot_key_code
    return language.iso_code + "." + dot_key_code
  end

=begin
  @return Language object for this translation
=end  
  def language
    return calmapp_versions_translation_language.translation_language
  end 
  
  def language_en?
    return language.iso_code == 'en'
  end
=begin
 @return the calmapp_version object of this translation  
=end  
  def calmapp_version
    return calmapp_versions_translation_language.calmapp_version_tl
  end
=begin
 When a new English translation is added then this method adds the same dot key codes for every 
 other language (for the same version)
=end  
  def is_plural? 
    return true  if (not(calmapp_versions_translation_language.nil?)) && language().iso_code == 'en' && special_structure == TRANS_PLURAL
    dkc = dot_key_code   
    english = english_translation_object #english_translations.where{dot_key_code == my{dkc}}
    #if english.exists?
    return english.special_structure == TRANS_PLURAL
    #end
    #return false 
  end
  
  def is_array13null?
    return true  if (not(calmapp_versions_translation_language.nil?)) && language().iso_code == 'en' && special_structure == TRANS_ARRAY_13_NULL
    dkc = dot_key_code   
    english = english_translation_object#english_translations.where{dot_key_code == my{dkc}}
    #if english.exists?
      return english.special_structure == TRANS_ARRAY_13_NULL
    #end
    #return false 
  end
  
  def is_array7?
    return true  if (not(calmapp_versions_translation_language.nil?)) && language().iso_code == 'en' && special_structure == TRANS_ARRAY_7
    dkc = dot_key_code   
    english = english_translation_object#english_translations.where{dot_key_code == my{dkc}}
    #if english.exists?
      return english.special_structure == TRANS_ARRAY_7
   # end
    #return false 
  end
  
  def is_order_array?
    return true  if (not(calmapp_versions_translation_language.nil?)) && language().iso_code == 'en' && special_structure == TRANS_ORDER_ARRAY
    dkc = dot_key_code   
    english = english_translation_object#english_translations.where{dot_key_code == my{dkc}}
    #if english.exists?
      return english.special_structure == TRANS_ORDER_ARRAY
    #end
    #return false 
  end
  
  def show_me
    "TRAN " + dot_key_code + " " + translation + " " + calmapp_versions_translation_language.show_me + " tran-id=" +id.to_s
  end
=begin
 When a new English translation is added then this method adds the same dot key codes for every 
 other language (for the same version)
 @callback
=end  
  def add_other_language_records_to_version   
   calmapp_version().translation_languages.each do |tl|
     if not tl.iso_code == 'en' then
       cavtl=  CalmappVersionsTranslationLanguage.where{calmapp_version_id  == my{calmapp_version.id}}.where{translation_language_id == my{tl.id}}.first       
       #if tl.plurals_same_as_en? || (not Translation.dot_key_code_plural?(dot_key_code,calmapp_version.id))
         t = Translation.new(:dot_key_code => dot_key_code, :cavs_translation_language_id => cavtl.id)#, :incomplete => true)
         t.save!
       #else
         #BulkTranslations.save_new_plurals(tl.plurals, dot_key_code, cavtl, true)
       #end # else not same as en
     end  # not en
   end  #do each tl
  end #def
  
=begin @deprecated
  def self.save_multiple translation_array
    transaction do 
      translation_array.each do |t|
        t.save!
      end
    end
  end
=end  
  
  
=begin
 If an english translation is deleted then thast dot_key for all other translations in that calmapp_version need to be deleted
 @todo add destroy translation_hints, 
 @callback 
=end  
  def delete_similar_dot_keys_not_english#(dkc, version_id)
    dkc = dot_key_code
    version_id = calmapp_versions_translation_language.calmapp_version_tl.id
    my_id = id
    ar_relation = Translation.
         joins(:calmapp_versions_translation_language  => [:calmapp_version_tl, :translation_language]).
         select("translation_languages.iso_code, translations.translation, translations.id").
         where{translations.dot_key_code == my{dkc}}.
         where{calmapp_versions.id == version_id}.
         where{ translations.id != my{my_id}}
    to_be_destroyed_count = ar_relation.size
    ar_relation.each{ |arr| Translation.find(arr.id).destroy}
    #destroyed_count = ar_relation.destroy_all
    puts "English record destroyed"
    #puts "To be additionally destroyed = " + to_be_destroyed_count.to_s
    puts "Have been additionally destroyed = " + to_be_destroyed_count.to_s
  end

  
  @@operators = Operators.new
  def self.ops
    return @@operators
  end

  
  def self.search_dot_key_code_operators
     [ ops.starts_with, ops.ends_with,  ops.matches,  ops.does_not_match,  ops.equals ]
  end

  def self.search_translation_operators
    [ ops.starts_with,  ops.ends_with,  ops.matches,  ops.does_not_match,  ops.equals,  ops.is_null,  ops.not_null]
  end
  def self.valid_criteria? search_info
    if search_info[:criteria]["cavtl_id"].nil? then
=begin      
      if search_info[:criteria]["iso_code"].nil? then
        message = I18n.t($ARA + "translation.iso_code") + " " + I18n.t($EM + "blank", "iso_code" )
        search_info[:messages]=[] if search_info[:messages].nil?
        search_info[:messages] << {"iso_code" => message}
      end
      
      if search_info[:criteria]["cav_id"].nil? then
        message = I18n.t($ARA + "translation.cav_id") + " " + I18n.t($EM + "blank", "cav_id" )
        search_info[:messages]=[] if search_info[:messages].nil?
        search_info[:messages] << {"criterion_cav_id" => message}
      end
=end
      
        message = I18n.t($ARA + "translation.cavtl_id") + " " + I18n.t($EM + "blank", "cavtl_id" )
        search_info[:messages]=[] if search_info[:messages].nil?
        search_info[:messages] << {"cavtl_id" => message}
    else
      
    end  
    return search_info[:messages].empty?
  end
  
=begin
 @return true if dot_key has a plural in translations 
=end
  def self.dot_key_code_plural?(dot_key, version_id)
    ret_val = Translation.outer_joins_special_dot_keys_arr.
    join_to_cavs_tls_arr(version_id).
    only_cldr_plurals_arr.
    where{dot_key_code == dot_key}.
    #where{cavtl1.calmapp_version_id == version_id}
    where("cavtl1.calmapp_version_id = ?", version_id)
    
    return ! ret_val.empty?  
    #SpecialPartialDotKey.select("partial_dot_key_code").where{my{dot_key_code} =~ partial_dot_key }.first#.cldr
  end

=begin
  
=end  
  def self.create_json_plural_template(plural_keys)
    translation_hash = {}
    plural_keys.each do |k|
      translation_hash[k]=''
    end #each
    translation_json = ActiveSupport::JSON.encode(translation_hash)
    return translation_json
  end
  
=begin
  
=end
   def self.create_json_array_template(size, first_element_null)
     arr = Array.new(size)
     arr[0] = nil if first_element_null
     return ActiveSupport::JSON.encode(arr) 
   end  
=begin
  # overrides search() in search_model.rb
  @param ar_relation will be used as the starting point
  @param search_info must contain criteria and operators for iso_code and calamapp_version_id unless ar_relation is not nil
  @param  conditions_between_joined_tables an array of strings with where clauses (eg "english.updated_at < translations.updated_at")
=end  
  def self.search(current_user, search_info={}, ar_relation = nil, conditions_between_joined_tables = [])
    criteria = search_info[:criteria]
    operators = search_info[:operators]
    sorting = search_info[:sorting]
    # We get the first instance of activerecord_relation, then use it to add the rest of the user input criteria
    if not ar_relation.nil? then
      translations = ar_relation
    else
      if not criteria["cavtl_id"].blank? then
        translations = single_lang_version_translations_arr( criteria.delete("cavtl_id"))
        operators.delete("cavtl_id")
      else
        translations = single_lang_translations_arr(criteria.delete("iso_code"), criteria.delete("cav_id"))
        operators.delete("iso_code")
        operators.delete("cav_id")
      end
    end
    # We need to do this for dot key code otherwise it will split on '.'
    # in and not_in are a bit shakey. They come to the controller as lists as a string. So we try to split
    # using space, or comma
    if criteria['dot_key_code'] then
      if operators['dot_key_code'] == 'in' || operators['dot_key_code'] == 'not_in' then
        array = criteria['dot_key_code'].split(" ")
        if array.size == 1 then
          array = criteria['dot_key_code'].split(", ")
          if array.size == 1 then
            array = criteria['dot_key_code'].split(",")
            criteria['dot_key_code']= array
          end # size
        else
          criteria['dot_key_code']= array  
        end # size
      end
    end # dot_key_code
    translations = build_lazy_loader(translations, criteria, operators)
    #Now we have an extra condition involving a joined table
    if not conditions_between_joined_tables.empty? then
      conditions_between_joined_tables.each do |str|
        translations = translations.where(str)
      end
    end
    return translations
  end
  
  def to_s
    return dot_key_code + ":" + translation + "(" + language.name + ")"
  end
=begin
 The node must be a hash
 All of the keys inside the has must be in Cldr.PLURALS 
 This should be used only when writing english translations
=end
  def self.plural_hash? node   
    if node.is_a? Hash then
      return is_plural_hash? node
    else
      return false
    end  
  end
  
  def self.is_plural_hash? hash
     keys = hash.keys
      if keys.empty?
        return false
      end
      keys.each{|k|
        if not CldrType.PLURALS.include?(k) then
          return false
        end 
      }
      return true
  end
  def ensure_translation_valid_json  
    #return  if translation.blank? 
    #return  if JSON.is_json? translation 
    # We use ActiveSupport::JSON.decode/encode here rather than JSON.parse/to_json as they seems to work with Strings 
    # and things like "%{attribute} %{value}"
   # if translation.is_a? String
      #translation2 = ActiveSupport::JSON.encode(translation)#translation.to_json
      if not JSON.is_json? translation then
        #translation = translation2
        #return true
      #else
        #errors.add(:translation, "String cannot be parsed/encoded to json")
        #return false
        self.translation = ActiveSupport::JSON.encode(translation)
      end
    #else
      #errors.add(:translation, "translation must be a string")
      #return false  
    #end
  end
 
  def self.translation_language_from_param language
    if language.is_a? TranslationLanguage then
      return language = language.iso_code
    elsif language.is_a? String then
      # then we assume that it is the iso_code
      return language
    elsif language.is_a? Integer then   
      return language = TranslationLanguage.find(language).iso_code
    else
      # Throw and exception to log it
      begin
        raise StandardError.new
      rescue Exception => e
        Rails.logger.error "Programming Error. Invalid param given to Translation.translation_language_from_param. Param should be TranslationLanguage instance or String for iso_code or Integer for id. Param is: " + language.class.name
        #bc = BacktraceCleaner.new
        #bc.add_filter   { |line| line.gsub(Rails.root.to_s, '') } # strip the Rails.root prefix
        #bc.add_silencer { |line| line =~ /mongrel|rubygems/ } # skip any lines from mongrel or rubygems
        
        #bc.clean(e.backtrace) # perform the cleanup
        caller.map{ |line| 
          #puts line
          Rails.logger.error line}
      end
    end
  end
  
=begin
  @param cavtl_alias_identifier a number(or string) to help uniquely identify the sql alias for calmapp_versions_translation_languages. Use this for complex self joins etc
  @return AR Relation with a join between translations and  calmapp_versions_translation_languages
  joins  calmapp_versions_translation_languages to translations
=end  
  scope :join_to_cavs_tls_arr, ->(calmapp_version_id, cavtl_alias_identifier = 1, translations_alias='translations', extra_and_clause = '' ) {
    cavtl_alias = "cavtl" + cavtl_alias_identifier.to_s() 
    joins("inner join calmapp_versions_translation_languages " + cavtl_alias + " on " + translations_alias + ".cavs_translation_language_id = " + cavtl_alias + ".id" + " and " + cavtl_alias +".calmapp_version_id = " + calmapp_version_id.to_s + extra_and_clause)
  }
=begin
  @param cavtl_alias_identifier a number(or string) to help uniquely identify the sql alias for calmapp_versions_translation_languages. Use this for complex self joins etc
  @param tl_alias_identifier a number(or string) to help uniquely identify the sql alias for translation_languages. Use this for complex self joins etc
  @return AR Relation with a join between translation_languages and  calmapp_versions_translation_languages
  joins  calmapp_versions_translation_languages to translation_languages
=end
  scope :joins_to_tl_arr, ->(cavtl_alias_identifier = 1, tl_alias_identifier = 1, join_type= 'inner join', extra_and_clause = '') {
    cavtl_alias = "cavtl" + cavtl_alias_identifier.to_s() 
    tl_alias = "tl" + tl_alias_identifier.to_s() 
    joins(join_type + " translation_languages " + tl_alias + " on " + cavtl_alias + ".translation_language_id = " + tl_alias +".id" + extra_and_clause)
  }
=begin
 @return a AR Relation that outer joins translations to translations to dot_key_code_translation_editors 
 Ensures all translations are selected even if they do not have an editor
=end  
  scope :outer_joins_editor_arr, -> {
    joins("left join dot_key_code_translation_editors dkcte on dkcte.dot_key_code = translations.dot_key_code")
  }
  
=begin
 This selects an indication that the key has plurals that have to be dealt with according to the language 
=end  
  scope :outer_joins_special_dot_keys_arr, -> {
    #left join  special_partial_dot_keys as special on translations.dot_key_code  ilike  special.partial_dot_key  and special.cldr ='t'
    joins("left join special_partial_dot_keys as special on translations.dot_key_code  ilike  special.partial_dot_key")#  and special.cldr = 't'")
  }
=begin
 @ return the select list for the basic selection on translations, including translation_language.iso_code and dot_key_code_translation_editors.editor 
=end  
  scope :basic_select_arr, -> {
    select("translations.id as id, tl1.iso_code as iso_code, translations.dot_key_code as dot_key_code, dkcte.editor as editor")
  }
  
  
  scope :outer_join_to_english_arr, ->( calmapp_version_id, equal=true ){
    if equal then
      operator = ' = '
    else 
      operator = ' != ' 
    end
    joins("full  join translations as english on translations.dot_key_code " + operator + " english.dot_key_code
          and english.cavs_translation_language_id = (select id from calmapp_versions_translation_languages as cavtl2 
          where cavtl2.calmapp_version_id = " + calmapp_version_id.to_s  +
  #       "  and cavtl2.translation_language_id = " + TranslationLanguage.TL_EN.id.to_s  + ")")
          " and cavtl2.translation_language_id = (select id from translation_languages as tl2 where tl2.iso_code = 'en'))")
  }

  scope :outer_join_to_english_arr_old, ->(equal=true ){
    if equal then
      operator = ' = '
    else 
      operator = ' != ' 
    end
    joins("full  join translations as english on translations.dot_key_code " + operator + " english.dot_key_code")
  }





=begin
  @return all translations, joined to english translations and editor and plurals 
  @param language expects translation_language.iso_code but  can also give id or TranslationLangauge object
  @param calmapp_version_id identifies the relevant version
  All attributes, including those from other objects that are selected appear in translation.attributes, presumably not updatable. 
  use result[n].attributes to get the data you need
  eg 
  > x = Translation.single_lang_translations('cs',1).first.attributes
  => {"id"=>en.menus.user_admin673,
 "iso_code"=>"cs",
 "dot_key_code"=>"activerecord.errors.messages.empty",
 "editor"=>nil,
 "en_translation"=>"can't be empty",
 "en_updated_at"=>2014-04-23 23:34:48 UTC,
 "translation"=>"nesmí být prázdný/á/é",
 "updated_at"=>Wed, 23 Apr 2014 23:58:41 UTC +00:00,
 "cldr"=>nil}

 NB cldr = nil means that the dot_key_code does not have plurals to translate 
=end 
  scope :single_lang_translations_arr, ->(language, calmapp_version_id) {
    language  = translation_language_from_param(language)
    join_to_cavs_tls_arr(calmapp_version_id).
    joins_to_tl_arr.
    outer_join_to_english_arr(calmapp_version_id).
    outer_joins_editor_arr.
    outer_joins_special_dot_keys_arr.
    #only_cldr_plurals.
    basic_select_arr.
    select("english.translation as en_translation, english.updated_at as en_updated_at, translations.translation as translation, 
          tl1.name as language, tl1.iso_code as iso_code,
          translations.updated_at as updated_at, special.cldr as cldr, cavtl1.calmapp_version_id as version_id, 
          english.special_structure as special_structure, translations.incomplete as incomplete").
    where( "cavtl1.calmapp_version_id = ?",calmapp_version_id).
    where("tl1.iso_code = ?", language).
    order("translations.dot_key_code asc")
  }
=begin
 Shockingly inefficient. Rewrite using association joins (or none with assoc joins)
=end  
  scope :single_lang_version_translations_arr, ->(cavtl_id) {
    cavtl = CalmappVersionsTranslationLanguage.find(cavtl_id)
    single_lang_translations_arr(cavtl.translation_language_id, cavtl.calmapp_version_id)
  }

=begin
 dependency scope outer_joins_special_dot_keys_arr will give cldr attr 
=end
  scope :only_cldr_plurals_arr, -> {
    where("cldr = ?", true)
  }

end


