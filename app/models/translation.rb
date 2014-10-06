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
  scope :single_lang_translations_arr_old, ->(language, calmapp_version_id) {
    if language.is_a? TranslationLanguage then
      language = language.iso_code
    elsif language.is_a? String then
      # then we assume that it is the iso_code
    elsif language.is_a? Integer then   
      language = TranslationLanguage.find(language)
    else
      puts "language is a " + language.class.name
      # raise error
    end
    join_to_cavs_tls_arr(calmapp_version_id).
    joins_to_tl_arr.
    outer_join_to_english_arr.
    join_to_cavs_tls_arr(calmapp_version_id, 2, "english", " and cavtl1.calmapp_version_id = cavtl2.calmapp_version_id").
    
    #joins("inner join calmapp_versions_translation_languages cavtl2 on english.cavs_translation_language_id = cavtl2.id and cavtl1.calmapp_version_id = cavtl2.calmapp_version_id ").
    # we need to make this a left (Outer) join because of the full outer join on transltions joined to english translations.
    # this allows for plurals that are in some languages but not in english e.g "few"
    joins_to_tl_arr(2, 2, 'left join', " and tl2.iso_code='en'").
    #joins("inner join translation_languages tl2 on cavtl2.translation_language_id = tl2.id and tl2.iso_code='en'").
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
=end  


=begin
  @return all translations, joined to english translations and editor and plurals 

  @param language expects translation_language.iso_code but  can also give id or object
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
    if language.is_a? TranslationLanguage then
      language = language.iso_code
    elsif language.is_a? String then
      # then we assume that it is the iso_code
    elsif language.is_a? Integer then   
      language = TranslationLanguage.find(language)
    else
      puts "language is a " + language.class.name
      # raise error  scope :outer_join_to_english_arr2, ->( calmapp_version, equal=true ){
=begin
    if equal then
      operator = ' = '
    else 
      operator = ' != ' 
    end
    joins("full  join translations as english on translations.dot_key_code " + operator + " english.dot_key_code
          and english.cavs_translation_language_id = (select id from calmapp_versions_translation_languages as cavtl2 where cavtl2.calmapp_version = " + calmapp_version_id.to_s  +
        + "  and cavtl2.translation_language_id = " + TranslationLanguage.TL_EN.id.to_s  + "))")
=end
    end
    join_to_cavs_tls_arr(calmapp_version_id).
    joins_to_tl_arr.
    outer_join_to_english_arr(calmapp_version_id).
    #join_to_cavs_tls_arr(calmapp_version_id, 2, "english", " and cavtl1.calmapp_version_id = cavtl2.calmapp_version_id").
    
    #joins("inner join calmapp_versions_translation_languages cavtl2 on english.cavs_translation_language_id = cavtl2.id and cavtl1.calmapp_version_id = cavtl2.calmapp_version_id ").
    # we need to make this a left (Outer) join because of the full outer join on transltions joined to english translations.
    # this allows for plurals that are in some languages but not in english e.g "few"
    # joins_to_tl_arr(2, 2, 'left join', " and tl2.iso_code='en'").
    #joins("inner join translation_languages tl2 on cavtl2.translation_language_id = tl2.id and tl2.iso_code='en'").
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
 @return all translations where translation is nil ie need to be translated 
=end
=begin @deprecated  
  scope :new_single_lang_arr, ->(language, calmapp_version_id) {
    single_lang_translations_arr(language, calmapp_version_id).
    where{translations.translation == nil}scope :single_lang_translations_arr2, ->(language, calmapp_version_id) {
    if language.is_a? TranslationLanguage then
      language = language.iso_code
    elsif language.is_a? String then
      # then we assume that it is the iso_code
    elsif language.is_a? Integer then   
      language = TranslationLanguage.find(language)
    else
      puts "language is a " + language.class.name
      # raise error
    end
    join_to_cavs_tls_arr(calmapp_version_id).
    joins_to_tl_arr.
    outer_join_to_english_arr2.
    #join_to_cavs_tls_arr(calmapp_version_id, 2, "english", " and cavtl1.calmapp_version_id = cavtl2.calmapp_version_id").
    
    #joins("inner join calmapp_versions_translation_languages cavtl2 on english.cavs_translation_language_id = cavtl2.id and cavtl1.calmapp_version_id = cavtl2.calmapp_version_id ").
    # we need to make this a left (Outer) join because of the full outer join on transltions joined to english translations.
    # this allows for plurals that are in some languages but not in english e.g "few"
    # joins_to_tl_arr(2, 2, 'left join', " and tl2.iso_code='en'").
    #joins("inner join translation_languages tl2 on cavtl2.translation_language_id = tl2.id and tl2.iso_code='en'").
    outer_joins_editor_arr.
    outer_joins_special_dot_keys_arr.
    only_cldr_plurals.
    basic_select_arr.
    select("english.translation as en_translation, english.updated_at as en_updated_at, translations.translation as translation, 
          tl1.name as language,
          translations.updated_at as updated_at, special.cldr as cldr").
    where( "cavtl1.calmapp_version_id = ?",calmapp_version_id).
    where("tl1.iso_code = ?", language).
    order("translations.dot_key_code asc")
  }

scope :outer_join_to_english_arr2, ->( calmapp_version_id, equal=true ){
  if equal then
    operator = ' = '
  else 
    operator = ' != ' 
  end
  joins("full  join translations as english on translations.dot_key_code " + operator + " english.dot_key_code
        and english.cavs_translation_language_id = (select id from calmapp_versions_translation_languages as cavtl2 where cavtl2.calmapp_version_id = " + calmapp_version_id.to_s  +
      + "  and cavtl2.translation_language_id = " + TranslationLanguage.TL_EN.id.to_s  +"))")
}
  }
=end
  
=begin
  @return all new and newly updated translations for the language and version 
=end
=begin @deprecated  
  scope :new_updated_single_lang_arr, ->(language, calmapp_version_id) {
    single_lang_translations_arr(language,calmapp_version_id).
    where{(translations.translation == nil) | (translations.updated_at > english.updated_at )}
  }
=end  
=begin
 @return   AR Relation with all english translations for a version
=end 
=begin @deprecated 
  scope :english_translations, ->(calmapp_version_id) {
    join_to_cavs_tls_arr.
    joins_to_tl_arr.
    joins_editor.
    basic_select_arr.
    where( "cavtl1.calmapp_version_id = ?",calmapp_version_id).
    where("tl1.iso_code =  'en'" )
  }
=end  
=begin
 @return AR Relation with where clause precluding all dot_ley_codes that end in a CLDR plural 
=end 
=begin @deprecated 
  scope :not_in_cldr_plurals_arr, ->{
    conditions = ""
    pl  = CldrType.CLDR_plurals.each do |p|
      p.prepend '%.'  
      if  conditions.length > 0 then
        conditions.concat ' and '    
      end 
      conditions.concat " dot_key_code not like  '#{p}'"  
    end
    return where(conditions)
  }
=end
=begin  
  scope :dot_key_codes_for_language, ->(language, calmapp_version_id) {
    
  }   
=end
=begin
  scope :english_codes_missing_in_translation_arr, ->(language, calmapp_version_id) {
    select("dot_key_code"). 
    join_to_cavs_tls_arr.
    joins_to_tl_arr.
    where("tl1.iso_code = 'en'").
    where("cavtl1.calmapp_version_id = ?", calmapp_version_id).
    not_in_cldr_plurals.
    where{dot_key_code << (Translation.select("dot_key_code").
    # we don't do a join between query and subquery because of the problems with aliases. Instead use the version data twice.
             join_to_cavs_tls_arr.
             joins_to_tl_arr.
             where( "tl1.iso_code = ?", language).
             where( "cavtl1.calmapp_version_id = ?", calmapp_version_id))
         }
  }
=end

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
   #calmapp_versions_translation_language.each do |cavtl|
   
     if not tl.iso_code == 'en' then
       
       cavtl=  CalmappVersionsTranslationLanguage.where{calmapp_version_id  == my{calmapp_version.id}}.where{translation_language_id == my{tl.id}}.first
       
       #cavtl = CalmappVersionsTranslationLanguage.new(:calmapp_version_id=>calmapp_version.id, :translation_language=> tl.id)
       #cavtl.save!
       
       if tl.plurals_same_as_en? || (not Translation.dot_key_code_plural?(dot_key_code,calmapp_version))
         t = Translation.new(:dot_key_code => dot_key_code, :cavs_translation_language_id => cavtl.id)
         save!
       else
         #
         # We must sort out the plurals and insert the correct plurals, not the ones from English
         #plurals = tl.plurals
         
         BulkTranslations.save_new_plurals(tl.plurals, dot_key_code, cavtl)
       end # else not same as en
     end  # not en
   end  #do each tl
  end #def


=begin
  def english_translation 
    new_locale = replace_locale_in_dot_key_code('en')
    en = Translation.where{dot_key_code == my{new_locale}}
    puts  en.all.to_s
    return en
  end
  def translation_locale 
    dot_key_code[0..(dot_key_code.index('.')-1)]
  end
  def remove_locale_from_dot_key_code
    dot_key_code[(dot_key_code.index('.')+1)..(dot_key_code.size() -1)]
  end
  def replace_locale_in_dot_key_code new_locale
    new_locale + '.' +remove_locale_from_dot_key_code
  end
=end

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
    #"Search criteria for both language and application version must be given. Given version = " + (params["criterion_cav_id"].nil?? "nil":["criterion_cav_id"].to_s)  + ". Given language = " + (params["criterion_iso_code"].nil?? "nil":["criterion_iso_code"].to_s))
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
    join_to_cavs_tls_arr.
    only_cldr_plurals_arr.
    where{dot_key_code == dot_key}.
    where{cavtl1.calmapp_version_id == version_id}
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
 
=begin   
  def self.write_new_dot_keys_for_all_languages calmapp_versions_translation_language
    calmapp_versions_translation_language.translation_languages.each do |tl|
      dot_key_codes  = translations_present_in_en_not_in_language(tl)
      dot_key_codes.each do |dkc|
        if not Translation.where{cavs_translation_language_id ==  calmapp_versions_translation_language.id}.where{dot_key_code == dkc}.exists?
           write_new_dot_key(calmapp_versions_translation_language, dkc)
        end
      end
    end
  end
  
  def write_new_dot_key calmapp_versions_translation_language, dkc
    Translation.create(:dot_key_code=> dkc, :cavs_translation_language_id => calmapp_versions_translation_language.id)
  end
=end
=begin
 def publish_translation(calmapp_versions_redis_database)
   calmapp_versions_redis_database = CalmappVersionsRedisDatabase.find(calmapp_versions_redis_database) if calmapp_versions_redis_database.is_a?(Integer)
    
 end
=end
end


