class Translation < ActiveRecord::Base
  # needed for self.search
  extend SearchModel
  include SearchModel
  
  belongs_to :calmapp_versions_translation_language, :foreign_key => "cavs_translation_language_id"
  belongs_to :translations_upload
  
  after_create :add_other_language_records_to_version, :if => Proc.new { |translation| translation.language.iso_code=='en'}
  validates :dot_key_code, :uniqueness=>{:scope=> :cavs_translation_language_id},  :presence=>true 
  validates :calmapp_versions_translation_language, :presence => true
  attr_accessor  :english, :criterion_iso_code, :criterion_cav_id, :written 
=begin
  @param cavtl_alias_identifier a number(or string) to help uniquely identify the sql alias for calmapp_versions_translation_languages. Use this for complex self joins etc
  @return AR Relation with a join between translations and  calmapp_versions_translation_languages
  joins  calmapp_versions_translation_languages to translations
=end  
  scope :join_to_cavs_tls, ->(cavtl_alias_identifier = 1, translations_alias='translations', extra_and_clause = '' ) {
    cavtl_alias = "cavtl" + cavtl_alias_identifier.to_s() 
    joins("inner join calmapp_versions_translation_languages " + cavtl_alias + " on " + translations_alias + ".cavs_translation_language_id = " + cavtl_alias + ".id" + extra_and_clause)
  }
=begin
  @param cavtl_alias_identifier a number(or string) to help uniquely identify the sql alias for calmapp_versions_translation_languages. Use this for complex self joins etc
  @param tl_alias_identifier a number(or string) to help uniquely identify the sql alias for translation_languages. Use this for complex self joins etc
  @return AR Relation with a join between translation_languages and  calmapp_versions_translation_languages
  joins  calmapp_versions_translation_languages to translation_languages
=end
  scope :joins_to_tl, ->(cavtl_alias_identifier = 1, tl_alias_identifier = 1, extra_and_clause = '') {
    cavtl_alias = "cavtl" + cavtl_alias_identifier.to_s() 
    tl_alias = "tl" + tl_alias_identifier.to_s() 
    joins("inner join translation_languages " + tl_alias + " on " + cavtl_alias + ".translation_language_id = " + tl_alias +".id" + extra_and_clause)
  }
=begin
 @return a AR Relation that outer joins translations to translations to dot_key_code_translation_editors 
 Ensures all translations are selected even if they do not have an editor
=end  
  scope :joins_editor, -> {
    joins("left join dot_key_code_translation_editors dkcte on dkcte.dot_key_code = translations.dot_key_code")
  }
  
=begin
 This selects an indication that the key has plurals that have to be dealt with according to the language 
=end  
  scope :joins_cldr, -> {
    #left join  special_partial_dot_keys as special on translations.dot_key_code  ilike  special.partial_dot_key  and special.cldr ='t'
    joins("left join special_partial_dot_keys as special on translations.dot_key_code  ilike  special.partial_dot_key  and special.cldr ='t'")
  }
=begin
 @ return the select list for the basic selection on translations, including translation_language.iso_code and dot_key_code_translation_editors.editor 
=end  
  scope :basic_select, -> {
    select("translations.id as id, tl1.iso_code as iso_code, translations.dot_key_code as dot_key_code, dkcte.editor as editor")
  }
  
  scope :outer_join_to_english, ->(equal=true ){
    if equal then
      operator = ' = '
    else 
      opeartor = ' != ' 
    end
    joins("left  join translations as english on translations.dot_key_code " + operator + " english.dot_key_code")
  }
=begin
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

 
=end 
  scope :single_lang_translations, ->(language, calmapp_version_id) {
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
    join_to_cavs_tls.
    joins_to_tl.
    outer_join_to_english.
    join_to_cavs_tls(2, "english", " and cavtl1.calmapp_version_id = cavtl2.calmapp_version_id").
    
    #joins("inner join calmapp_versions_translation_languages cavtl2 on english.cavs_translation_language_id = cavtl2.id and cavtl1.calmapp_version_id = cavtl2.calmapp_version_id ").
    joins_to_tl(2, 2, " and tl2.iso_code='en'").
    #joins("inner join translation_languages tl2 on cavtl2.translation_language_id = tl2.id and tl2.iso_code='en'").
    joins_editor.
    joins_cldr.
    basic_select.
    select("english.translation as en_translation, english.updated_at as en_updated_at, translations.translation as translation, 
          tl1.name as language,
          translations.updated_at as updated_at, special.cldr as cldr").
    where( "cavtl1.calmapp_version_id = ?",calmapp_version_id).
    where("tl1.iso_code = ?", language).
    order("translations.dot_key_code asc")
  }
  
  scope :new_single_lang, ->(language, calmapp_version_id) {
    single_lang_translations(language, calmapp_version_id).
    where{translations.translation == nil}
  }
=begin
  @return all new and newly updated translations for the language and version 
=end  
  scope :new_updated_single_lang, ->(language, calmapp_version_id) {
    single_lang_translations(language,calmapp_version_id).
    where{(translations.translation == nil) | (translations.updated_at > english.updated_at )}
  }  
=begin
 @return   AR Relation with all english translations for a version
=end  
  scope :english_translations, ->(calmapp_version_id) {
    join_to_cavs_tls.
    joins_to_tl.
    joins_editor.
    basic_select.
    where( "cavtl1.calmapp_version_id = ?",calmapp_version_id).
    where("tl1.iso_code =  'en'" )
  }
=begin
 @return AR Relation with where clause precluding all dot_ley_codes that end in a CLDR plural 
=end  
  scope :not_in_cldr_plurals, ->{
    conditions = ""
    pl  = Translation.CLDR_plurals.each do |p|
      p.prepend '%.'  
      if  conditions.length > 0 then
        conditions.concat ' and '    
      end 
      conditions.concat " dot_key_code not like  '#{p}'"  
    end
    return where(conditions)
  }
  
  scope :dot_key_codes_for_language, ->(language, calmapp_version_id) {
    
  }   
  scope :english_codes_missing_in_translation, ->(language, calmapp_version_id) {
    select("dot_key_code"). 
    join_to_cavs_tls.
    joins_to_tl.
    where("tl1.iso_code = 'en'").
    where("cavtl1.calmapp_version_id = ?", calmapp_version_id).
    not_in_cldr_plurals.
    where{dot_key_code << (Translation.select("dot_key_code").
    # we don't do a join between query and subquery because of the problems with aliases. Instead use the version data twice.
             join_to_cavs_tls.
             joins_to_tl.
             where( "tl1.iso_code = ?", language).
             where( "cavtl1.calmapp_version_id = ?", calmapp_version_id))
         }
  }
  scope :only_cldr_plurals, -> {
    where("cldr = ?", true)
  }

=begin
   cldr plurals (used for models and other things in translation files (different in different files))
  zero
  one (singular)
  two (dual)
  few (paucal)
  many
  other (general plural form -- also used if the language only has a single form, or for fractions if they are different)
=end
  def self.CLDR_plurals
    return %w(zero one two few many other)
  end

  def self.Overwrite
    # :all means all existing translations that are matched will be overwritten( except if the same as new)
    # :continue_unless_blank means that no existing translations(by language and dot_code_key) will be overwritten unless translation is null
    # :cancel means an the writing of a file will be rolled back if a duplicate language and key is found( where translation is not null )
    {:all=>"OVERWRITE_ALL", :continue_unless_blank=>"OVERWRITE_CONTINUE", :cancel => "CANCEL_OPERATION"}
  end
  def full_dot_key_code
    return language + "." + dot_key_code
  end
  
  def language
    return calmapp_versions_translation_language.translation_language
  end 
  
  def calmapp_version
    return calmapp_versions_translation_language.calmapp_version_tl
  end
  
  def add_other_language_records_to_version
     calmapp_version.translation_languages.each do |tl|
     #calmapp_versions_translation_language.each do |cavtl|
       if not tl.iso_code == 'en' then
         cavtl=  CalmappVersionsTranslationLanguage.where{calmapp_version_id  == my{calmapp_version.id}}.where{translation_language_id == my{tl.id}}.first
         #cavtl = CalmappVersionsTranslationLanguage.new(:calmapp_version_id=>calmapp_version.id, :translation_language=> tl.id)
         #cavtl.save!
         t = Translation.new(:dot_key_code => dot_key_code, :cavs_translation_language_id => cavtl.id)
         t.save!
       end  
     end
    
  end
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
    #debugger
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
=begin
   def self.searchable_attr 
    return %w[dot_key_code0 translation0 translation_message dot_key_code1 translation1 translation_message1 dot_key_code2 translation2  translation_message2]
  end
  def self.sortable_attr 
    return %w[dot_key_code0 translation0 translation_message dot_key_code1 translation1 translation_message1 dot_key_code2 translation2  translation_message2]
  end
=end
  def self.searchable_attr
    %w(iso_code dot_key_code cav_id translation)
  end
  
  def self.sortable_attr
    %w(dot_key_code translation translation)
  end
  def self.search_dot_key_code_operators
     [ ops.ends_with,  ops.matches,  ops.does_not_match,  ops.equals ]
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
    #binding.pry
    return search_info[:messages].empty?
  end
  
  # not working @todo
  def cldr?
    return SpecialPartialDotKey.where{my{dot_key_code} =~ partial_dot_key }.cldr
  end
  # overrides search() in search_model.rb
  def self.search(current_user, search_info={}, ar_relation = nil)
    criteria = search_info[:criteria]
    operators = search_info[:operators]
    sorting = search_info[:sorting]
    translations = single_lang_translations(criteria.delete("iso_code"), criteria.delete("cav_id"))
    operators.delete("iso_code")
    operators..delete("cav_id")
 
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

    #binding.pry
    translations = build_lazy_loader(translations, criteria, operators)
    #puts translations.class.name
    return translations
  end
=begin
 After a yaml translation file is uploaded this method writes the translation to the db
 @param hash. A hash containing the contents of the file keyed by dot_key_code
 @param translation_upload_id the upload from where the hash came
 @param the versiona dn language of the file contents
 @param overwrite any of self.Overwrite
 @return the written translation
=end  
  def self.translations_to_db_from_file hash, translation_upload_id, calmapp_versions_translation_language, overwrite
    keys =  hash.keys
    
    #keys.each{ |k| puts k + ": " + hash[k]}
    puts "Number of keys in hash to be written " + keys.count.to_s
    count=0
    translation = nil
    
    keys.each do |k|
      #binding.pry 
      translation = translation_to_db_from_file(k, hash[k], translation_upload_id, calmapp_versions_translation_language, overwrite)    
      #if translation.nil? or translation.errors.nil?
      #binding.pry
      #end
      if  translation.errors.count > 0 then
        return translation
      end
      
      count += 1 if translation.written
      
      #binding.pry
    end # do
    puts "keys written to db = " + count.to_s
    return translation
  end # def
=begin
  @param key is the iso_code + '.' + dot_key_code
  @param translation
  @param  translations_upload_id is the id of the upload if writing from an uploaded file 
  @param calmapp_versions_translation_language the version translation language for this translation
  @param the manner in which to handle existing dot keys in the db ( Translation.Overwrite[:all] 
       | Translation.Overwrite[:continue_unless_blank] | Translation.Overwrite[:cancel])
  Writes 1 key and translation to Translation 
  Writes all translations for en but for other locales, only translations that have a dot key code already in en
=end
  def self.translation_to_db_from_file key, translation,translations_upload_id, calmapp_versions_translation_language, overwrite
    split_hash= split_full_dot_key_code key
    language = calmapp_versions_translation_language.translation_language.iso_code
    dkc = split_hash[:dot_key_code]
    msg_data = "Translation: '" + translation + "' for " + language + " key " + dkc
    en_translation_exists = nil
    if language != 'en' then 
      
      en_translation_exists = english_translation_exists(calmapp_versions_translation_language, dkc)
      msg = "English translation exists for " + msg_data
      Rails.logger.info msg
      
    end
    if language == 'en' || en_translation_exists then
      exists = Translation.where{(dot_key_code == dkc) & (cavs_translation_language_id == calmapp_versions_translation_language.id)}#(language== split_hash[:language])} 
      #binding.pry
      if exists.count > 0
        object = exists.first
        puts "Dot_key_code already exists for " + msg_data
      end
      object_persisted = false
      #binding.pry
      
      if not object.nil?
        if overwrite == Translation.Overwrite[:all] then
            #msg = "Object to be persisted because 'all' parameter chosen"
            if object.translation != translation then
              b = object.update_attributes!(:translation=> translation, :cavs_translation_language_id => calmapp_versions_translation_language.id, :translations_upload_id=> translations_upload_id)
              #binding.pry
              object_persisted = true
              msg = "Object persisted: old translation: " + object.translation + " replaced with new translation: " + msg_data
              
            else
               msg = "Object to be prsisted is the same as already stored: " + msg_data
            end
            Rails.logger.info msg
            puts msg
            if object.nil? then
              binding.pry
            end  
            object.written = true
            return object
        elsif overwrite == Translation.Overwrite[:continue_unless_blank] then
          #puts "If duplicate key then continue unless translation blank"
          if object.translation.nil? then 
            #We update where the transaltion is nil anyway
            b = object.update_attributes!(:translation=> translation, :cavs_translation_language_id => calmapp_versions_translation_language.id, :translations_upload_id=> translations_upload_id)
            object_persisted = true
            msg = "overwrite: persisted anyway because tranlation blank: translation: " + msg_data
            Rails.logger.info msg
            puts msg
            object.written = true
          else
            # we do nothing here. The translation continues because we don't overwrite an existing translation
            object.written = false
            msg = "Existing translation not blank so nothing written for "  + msg_data
          end 
          Rails.logger.info msg
          puts msg
          return object
        elsif overwrite == Translation.Overwrite[:cancel]
          # object is already in db
          # We write it anyway if translation is null
          if object.translation.nil? then 
            #We update where the transaltion is nil anyway
            object.update_attributes!(:translation=> translation, :cavs_translation_language_id => calmapp_versions_translation_language.id, :translations_upload_id=> translations_upload_id)
            object_persisted = true
            msg = "Overwrite: persisted anyway because tranlation blank: translation: " + msg_data
            Rails.logger.info msg
            puts msg
            object.written = true
            return object
          else
            msg = "Cancelled because of duplicate dot_key_code: data " + msg_data
            Rails.logger.info msg
            puts msg
            t = Translation.new(:cavs_translation_language_id => calmapp_versions_translation_language.id, :dot_key_code=> dkc, :translation=>translation, :translations_upload_id => translations_upload_id)
            t.errors.add(:dot_key_code, I18n.t("messages.write_file_to_db.cancel", {:language=> language, :dot_key_code => object.dot_key_code}))
            t.written = false
            return t 
          end  
        else
          msg = "Invalid value for overwrite condition. Invalid value = " + overwrite + ". Data is " + msg_data
          object.errors.add(:base, msg)
          object.written = false
          return object
        end #overwrite condition
      else 
        #object is nil (not fouund in db)
        # if not overwrite or match language and keys count=0 then this code executes
        msg = "Write new translation: " + msg_data
        puts msg
        Rails.logger.info msg
        t = Translation.new(:cavs_translation_language_id => calmapp_versions_translation_language.id, :dot_key_code=> dkc, :translation=>translation, :translations_upload_id => translations_upload_id)
        t.save!       
        t.written = true
        return t 
      end # object is nil
    else
      #english translation does not exist
      msg = "English translation does not exist so not saving " + msg_data
      puts msg
      Rails.logger.info msg
      t = Translation.new(:cavs_translation_language_id => calmapp_versions_translation_language.id, :dot_key_code=> dkc, :translation=>translation, :translations_upload_id => translations_upload_id)
      return t
    end    
  end
  
=begin
 Splits a full_dot_key_code into language and dot_key_code (without language)
 #return hash keyed by ":language" and ":dot_key_code" 
=end  
  def self.split_full_dot_key_code full_dot_key_code
    code_array = full_dot_key_code.split(".") 
    return {:language=> code_array[0], :dot_key_code=> code_array[1..(code_array.length-1)].join(".")}
  end
  
  def self.english_translation_exists(calmapp_versions_translation_language, dkc)
    english_tl = TranslationLanguage.where{iso_code == 'en'}
    
    cav_id = calmapp_versions_translation_language.calmapp_version_id
    tl_id = english_tl.first.id
    english_calmapp_versions_translation_language = CalmappVersionsTranslationLanguage.where{(calmapp_version_id == my{cav_id}) & (translation_language_id ==  my{tl_id})}.first
    en_cav_tl_id = english_calmapp_versions_translation_language.id
    en_translation_ar_relation = Translation.where{(dot_key_code == my{dkc}) &  (cavs_translation_language_id == my{en_cav_tl_id})}
    english_translation_exists =  en_translation_ar_relation.count
    #binding.pry
    if english_translation_exists > 0 then
      return en_translation_ar_relation.first 
    else
      return nil
    end
  end
end


