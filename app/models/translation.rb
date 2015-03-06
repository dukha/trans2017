class Translation < ActiveRecord::Base
  # needed for self.search
  extend SearchModel
  include SearchModel
  
  belongs_to :calmapp_versions_translation_language, :foreign_key => "cavs_translation_language_id"
  belongs_to :translations_upload
  
  
  validates :dot_key_code, :uniqueness=>{:scope=> :cavs_translation_language_id},  :presence=>true 
  validates :calmapp_versions_translation_language, :presence => true
  attr_accessor  :english, :criterion_iso_code, :criterion_cav_id, :written#, :selection_mode 
  @@selection_mode
  def self.selection_mode mode
    @@selection = mode
  end
  def self.selection_mode
    @@selection_mode
  end
  after_create :add_other_language_records_to_version, :if => Proc.new { |translation| translation.language.iso_code=='en'}
  
  def self.searchable_attr
    %w(iso_code dot_key_code cav_id translation updated_at)
  end
  
  def self.sortable_attr
    %w(dot_key_code translation translation)
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
  => {"id"=>673,
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
          tl1.name as language,
          translations.updated_at as updated_at, special.cldr as cldr, cavtl1.calmapp_version_id as version_id").
    where( "cavtl1.calmapp_version_id = ?",calmapp_version_id).
    where("tl1.iso_code = ?", language).
    order("translations.dot_key_code asc")
  }

=begin
 dependency scope outer_joins_special_dot_keys_arr will give cldr attr 
=end
  scope :only_cldr_plurals_arr, -> {
    where("cldr = ?", true)
  }
  
=begin
  @return ActiveRecord::Relation of English translations for the same version of this translation   
=end  
  def english_translations 
    cav_id =  calmapp_versions_translation_language.calmapp_version_id
    cavtl_en =  CalmappVersionsTranslationLanguage.
           where{ calmapp_version_id == cavtl_id }.
           where{ translation_language_id == TranslationLanguage.TL_EN.id}.first
    return Translation.join{calmapp_version_translation_languages}.
           where{calmapp_versions_translation_languages.translation_language.id == cavtl_en.id}      
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
  def add_other_language_records_to_version
   calmapp_version().translation_languages.each do |tl|
     if not tl.iso_code == 'en' then
       cavtl=  CalmappVersionsTranslationLanguage.where{calmapp_version_id  == my{calmapp_version.id}}.where{translation_language_id == my{tl.id}}.first       
       if tl.plurals_same_as_en? || (not Translation.dot_key_code_plural?(dot_key_code,calmapp_version.id))
         #binding.pry
         t = Translation.new(:dot_key_code => dot_key_code, :cavs_translation_language_id => cavtl.id)
         t.save!
       else
         BulkTranslations.save_new_plurals(tl.plurals, dot_key_code, cavtl)
       end # else not same as en
     end  # not en
   end  #do each tl
  end #def

  def self.save_multiple translation_array
    transaction do 
      translation_array.each do |t|
        t.save!
      end
    end
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
    if search_info[:criteria]["iso_code"].nil? then
      message = message = I18n.t($ARA + "translation.iso_code") + " " + I18n.t($EM + "blank", "iso_code" )
      search_info[:messages]=[] if search_info[:messages].nil?
      search_info[:messages] << {"iso_code" => message}
    end
    
    if search_info[:criteria]["cav_id"].nil? then
      message = I18n.t($ARA + "translation.cav_id") + " " + I18n.t($EM + "blank", "cav_id" )
      search_info[:messages]=[] if search_info[:messages].nil?
      search_info[:messages] << {"criterion_cav_id" => message}
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
    #binding.pry
    return ! ret_val.empty?  
    #SpecialPartialDotKey.select("partial_dot_key_code").where{my{dot_key_code} =~ partial_dot_key }.first#.cldr
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
      translations = single_lang_translations_arr(criteria.delete("iso_code"), criteria.delete("cav_id"))
      operators.delete("iso_code")
      operators.delete("cav_id")
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
end


