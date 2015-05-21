=begin
 This class is an overflow class for writing bulk translations (from files) Translation   
=end
class BulkTranslations
  
  
=begin
  @param a calmapp_version_translation_language_instance  
  @return all english translations for the version 
=end  
  def self.english_translations calmapp_versions_translation_language
    cav_id = calmapp_versions_translation_language.calmapp_version_id
    CalmappVersionsTranslationLanguage.where{ calmapp_version_id == cav_id}.
       where{translation_language_id == TranslationLanguage.TL_EN.id}.first.translations
  end
  
=begin
 plural forms come in arrays like ['one', 'other'] or ['one', 'few', 'many', 'other']
 Given a dot key code which is identified adot_key_code ilikes a plural, this method will save all appropriate plurals
 for this dot key code, without translation
 @param plurals and array of plural forms
 @param dot_key_code
 @param cavtl The relevant calmapp_version_translation_language object for this dot key  
 @return array with saved plurals
=end  
  def self.save_new_plurals(plural_keys, dot_key_code, cavtl)#, plurals, translation = nil)
   # this array will have its last element overridden in each iteration of plurals.each
   dot_key_code_array = dot_key_code.split('.')
   # We now have to check if the dot_key_code without the plural is in the 'en' translation
   ret_val = []
   
   translation_hash = {}
   plural_keys.each do |k|
     translation_hash[k]=''
   end #each
   translation_json = translation_hash.to_json
   dkc = nil
   if CldrType.PLURALS.include?(dot_key_code_array.last) then
     dot_key_code_array = dot_key_code_array[0..(dot_key_code_array.length-2)]
     dkc = dot_key_code_array.join('.')
   else
     dkc = dot_key_code_array.join('.')
   end #include
   # Check that translations do not already exist
   t = Translation.where{cavs_translation_language_id == my{cavtl.id}}.where{dot_key_code = my{dkc}}
   if t.nil? then
     ret_val << Translation.new(:dot_key_code => dkc, :cavs_translation_language_id => cavtl.id, :translation => translation_json )
   else  
     begin
       JSON.parse t.translation
       ret_val << t
     rescue
       #if existing translation isnot json the write the new
       ret_val << Translation.new(:dot_key_code => dkc, :cavs_translation_language_id => cavtl.id, :translation => translation_json )
     end  #beginrescue
   end #nil?
   
=begin
 @deprecated 
  
   plural_keys.each do |p|
     if plural_keys.length == 1 && plural_keys[0] == 'other' then
       pl = save_one_new_plural('', dot_key_code_array, cavtl, plurals, translation)
     else
       pl = save_one_new_plural(p, dot_key_code_array, cavtl, plurals, translation)
     end
     pl.written = true
     ret_val << pl
   end # do each plural
=end    
   return ret_val 
  end #def


=begin
 if plural is '' then this will indicate the the plurals is "other" and so we don't use one,...other but just the normal odt keyy code with the single translation.   
 @param plural the plural form (string) to be saved 
 @param dot_key_code_split_array thet = Translation.new(:dot_key_code => new_dot_key_code, :cavs_translation_language_id => cavtl.id, :translation => translation, :plural => plurals[dot_key_code]) dot_key_code that was found (in array form) to be modified by a new plural form in this method
 @param cavtl The relevant calmapp_version_translation_language object for this dot key
 Should be now deprecated
=end  
  def self.save_one_new_plural(plural_key, dot_key_code_split_array, cavtl, plurals, translation = nil)
    ret_val = nil
    if plural_key != '' then
      if not dot_key_code_split_array[dot_key_code_split_array.length - 1] == plural_key then
        dot_key_code_split_array[dot_key_code_split_array.length - 1] = plural_key
        translation = nil
      end
    else  
      
    end
    new_dot_key_code = dot_key_code_split_array.join('.')
    
    msg_data = trans_msg_data(translation.to_s, cavtl.translation_language.iso_code, new_dot_key_code) 
    array = Translation.where{dot_key_code == new_dot_key_code}.where{cavs_translation_language_id == cavtl.id}
    if array.empty?
      # no match
      t = Translation.new(:dot_key_code => new_dot_key_code, :cavs_translation_language_id => cavtl.id, :translation => translation, :plural => plurals[dot_key_code])
      t.save!
      t.written = true
      msg = "Saved new plural translation " + msg_data
      puts msg
      Rails.logger.info msg  
      ret_val = t
    else
      # there is a record found
      if array.first.translation.nil? then
        if not translation.nil? then
          #if the existing translation is nil and the new translation is not nil then we update
          array.first.update!(:translation => translation)
          array.first.written=true
          msg = "Updated plural translation " + msg_data
          puts msg
          Rails.logger.info msg 
        else
          puts "Translation update is nil, so no change to record"
        end
      else
        puts "Existing translation already has data, so no update"
      end 
      ret_val = array.first
    end # not exists? 
    return ret_val 
  end
  
=begin
 After a yaml translation file is uploaded this method writes the translation to the db
 @param hash. A hash containing the contents of the file keyed by dot_key_code
 @param translation_upload_id the upload from where the hash came
 @param the versiona dn language of the file contents
 @param overwrite any of self.Overwrite
 @return the written translation
=end  
  def self.translations_to_db_from_file hash, translation_upload_id, calmapp_versions_translation_language, overwrite, plurals
    
    keys =  hash.keys
    puts "Number of keys in hash to be written " + keys.count.to_s
    count=0
    translation = nil
    language = calmapp_versions_translation_language.translation_language.iso_code
    plural_same_as_en = calmapp_versions_translation_language.translation_language.plurals_same_as_en?()
    keys.each do |k|
      translation = translation_to_db_from_file(k, hash[k], translation_upload_id, calmapp_versions_translation_language, plural_same_as_en, overwrite, plurals)    
      if translation.nil? then
        #this is the situation where the translation language is not en and the english translation for the saem dot key does not exist
        next
      end  
      if  translation.errors.count > 0 then
        return translation
      end
      
      count += 1 if translation.written
    end # do
    msg = "keys written to db >= " + count.to_s
    puts msg
    Rails.logger.info msg
    msg =  "Different types of plurals in different langauges mean that the above number is not exact"
    puts msg
    Rails.logger.info msg
    return translation
  end # def
=begin
 returns and loggable line for what data is being processed 
=end  
  def self.trans_msg_data(translation, language_iso_code, dkc)
    begin
      if translation.nil? || language_iso_code.nil? || dkc.nil?
        raise "Nil instead of value " + translation.to_s +  language_iso_code.to_s + dkc.toS
      end
    rescue StandardError => se
      puts se.backtrace.join("\n")
    end
    "Translation: '" + translation + "' for '" + TranslationLanguage.find_by(:iso_code => language_iso_code).name + "' key: " + dkc
  end
  
=begin
  @param key is the iso_code + '.' + dot_key_code
  @param translation
  @param  translations_upload_id is the id of the upload if writing from an uploaded file 
  @param calmapp_versions_translation_language the version translation language for this translation
  @param the manner in which to handle existing dot keys in the db ( Translation.Overwrite[:all] 
       | Translation.Overwrite[:continue_unless_blank] | Translation.Overwrite[:cancel])
  Writes 1 key and translation to Translation 
  Writes all translations for en but for other locales, only translations that have a dot key code already in en
  In the case of plurals, there must be a PARTIAL dot_key_code in en
=end
  def self.translation_to_db_from_file key, translation,translations_upload_id, calmapp_versions_translation_language, plural_same_as_en, overwrite, plurals
    split_hash= split_full_dot_key_code key
    language = calmapp_versions_translation_language.translation_language.iso_code
    dkc = split_hash[:dot_key_code]
    
    msg_data = trans_msg_data(translation, language, dkc)
    
    en_translation_exists = nil
    if language != 'en' then 
      en_translation_exists = english_translation_exists(calmapp_versions_translation_language, dkc)
      if en_translation_exists
        msg = "English translation exists for " + msg_data
      else
        msg = "English translation DOES NOT exists for " + msg_data + ' Cannot write translation unless English (en) translation exists'  
      end  
      Rails.logger.info msg
      return unless en_translation_exists
    end

    if not plural_same_as_en then
      plural_keys = calmapp_versions_translation_language.translation_language.plurals_array 
    else
      plural_keys = []
    end
    # We are interested in finding out if it is already a plural like .xxx.one or .xxx.other
    end_of_dkc = dkc.split('.').last
    if language == 'en' || 
        en_translation_exists || 
        (CldrType.CLDR_plurals.include?(end_of_dkc) && end_of_dkc != 'one' && end_of_dkc != 'other') then
      exists = Translation.where{(dot_key_code == dkc) & (cavs_translation_language_id == calmapp_versions_translation_language.id)}#(language== split_hash[:language])} 
      
      if exists.count > 0
        object = exists.first
        puts "Dot_key_code already exists for " + msg_data
      end
      if not JSON.is_json?(translation) then
        translation = translation.to_json
      end
      if not object.nil? then
         return do_overwrite_condition(dkc, translation, calmapp_versions_translation_language, translations_upload_id, overwrite, object, plural_keys, msg_data, plurals)
      else # object does not exist in db
        # if not overwrite or match language and keys count=0 then this code executes
        return do_new_condition(dkc, translation, calmapp_versions_translation_language, translations_upload_id, msg_data, plurals)
         
      end # object is nil
     
    else #language not en
      ret_val = non_english_plural_translations_to_db_from_file(dkc, translation, translations_upload_id, calmapp_versions_translation_language, plural_keys, msg_data, plurals)
      return ret_val
    end #language 
    msg = "Unknown error in plurals(2)" 
    ret_val =  unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, msg)
  end  #def


def self.non_english_plural_translations_to_db_from_file(dkc, translation, translations_upload_id, calmapp_versions_translation_language, plural_keys, msg_data, plurals)
      
      puts "catch all non- English plurals " + dkc
      if plurals.count > 0 then
        dkc_search_pl_min = nil
        if plurals.count == 1 && plurals[0] == 'other' then
          # In this case it is not necessary to use the ".other suffix" The key will suffice as a plural
          dkc_search_pl_min = dkc
        end
        dkc_split = dkc.split('.')
        dkc_search_pl = dkc_split[0..dkc_split.length-2].join('.') + ".other"
        cavtl = calmapp_versions_translation_language
        # we find the english translation of the same version
        en_version_tl_search_pl = CalmappVersionsTranslationLanguage.
           where{ calmapp_version_id == cavtl.calmapp_version_id }.
           where{ translation_language_id == TranslationLanguage.TL_EN.id}.first
        if en_version_tl_search_pl then    
          cavtl_en_id = en_version_tl_search_pl.id
          # We can now check if this is a plural   
          if ( Translation.outer_joins_special_dot_keys_arr.
                       only_cldr_plurals_arr.
                       where{cavs_translation_language_id == cavtl_en_id }.
                       where{dot_key_code =~ (dkc_search_pl + '%')}.exists?) then
             # If this is a plural situation then we still need to write it
             t_array = save_new_plurals(plural_keys, dkc, calmapp_versions_translation_language, plurals, translation )
             if t_array.is_a?(Array) && !t_array.empty? then
              ret_val= t_array.last  
             else
               msg "en translation exists but save_new plurals prduces only " + t_array.to_s
               ret_val = unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, msg)
             end
           elsif dkc_search_pl_min then
               if ( Translation.outer_joins_special_dot_keys_arr.
                         only_cldr_plurals_arr.
                         where{cavs_translation_language_id == cavtl_en_id }.
                         where{dot_key_code =~ (dkc_search_pl_min + '%')}.exists?) then
              # If this is a plural situation then we still need to write it
                  t_array = save_new_plurals(plurals, dkc, calmapp_versions_translation_language, plurals, translation )
                  if t_array.is_a?(Array) && !t_array.empty? then
                    ret_val= t_array.last
                  else
                    msg = "No partial Plural dot_key_code in english, even for other(1)."
                    ret_val = unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, msg)
                  end
               else # no t_array  for min dkc
                  msg = "No partial Plural dot_key_code in english, even for other(2)."
                  ret_val = unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, msg)       
               end #search for minimal key existing for en   
                
          else
            # not a plural
            #is the english a plural?
              msg = "No partial Plural dot_key_code in english."
              ret_val =  unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, msg)
          end # t_array stuff 
                
          #end  # partial plural dot key in en?
        else
          msg = "There was no version translation language found."
          ret_val =  unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, msg)
        end # was there a version translation language  found  
      else
        # we return a new record to indicate that we have not saved
        msg = "There are no plurals to be saved."
        ret_val =  unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, msg)
      end # are there plurals?
      if ret_val.nil? 
        msg = "Unknown error in plurals(2)" 
        ret_val =  unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, msg)
      end  
      return ret_val
end
=begin
  A record must be returned. Returning an unsaved record is the best way of allowing the return of the saved record
=end   
  def self.unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, message)
    
    msg = "English translation does not exist so not saving " + message + " " + msg_data
    puts msg
    Rails.logger.info msg
    ret_val = Translation.new(:cavs_translation_language_id => calmapp_versions_translation_language.id, :dot_key_code=> dkc, :translation=>translation, :translations_upload_id => translations_upload_id)
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
    english_tl = TranslationLanguage.TL_EN #TranslationLanguage.where{iso_code == 'en'}
    
    cav_id = calmapp_versions_translation_language.calmapp_version_id
    tl_id = english_tl.id
    english_calmapp_versions_translation_language = CalmappVersionsTranslationLanguage.where{(calmapp_version_id == my{cav_id}) & (translation_language_id ==  my{tl_id})}.first
    en_cav_tl_id = english_calmapp_versions_translation_language.id
    en_translation_ar_relation = Translation.where{(dot_key_code == my{dkc}) &  (cavs_translation_language_id == my{en_cav_tl_id})}
    english_translation_exists =  en_translation_ar_relation.count
    #
    if english_translation_exists > 0 then
      return en_translation_ar_relation.first 
    else
      return nil
    end
  end
  
  def self.full_key(calmapp_versions_translation_language, dkc)
    calmapp_versions_translation_language.translation_language.iso_code + "." + dkc
  end  
  
  def self.do_overwrite_condition(dkc, translation, calmapp_versions_translation_language, translations_upload_id, overwrite, object, plural_keys, msg_data, plurals)
    if overwrite == Translation.Overwrite[:all] then
            plural_key = full_key(calmapp_versions_translation_language, dkc)
            #msg = "Object to be persisted because 'all' parameter chosen"
            if object.translation != translation then
              b = object.update_attributes!(
                         :translation=> translation, 
                         :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                         :translations_upload_id=> translations_upload_id, 
                         plural: plural_value(plurals, plural_key)
                         )
              #
              #objecif not JSON.is_json?(translation) then
              translation = translation.to_json
            endt_persisted = true
              msg = "Object persisted: old translation: " + object.translation + " replaced with new translation: " + msg_data
              
            else
               msg = "Object to be persisted is the same as already stored: " + msg_data
            end
            Rails.logger.info msg
            puts msg
              
            object.written = true
            return object
        elsif overwrite == Translation.Overwrite[:continue_unless_blank] then
          #puts "If duplicate key then continue unless translation blank"
          if object.translation.nil? then 
            #We update where the translation is nil anyway
            b = object.update_attributes!(
                     :translation=> translation, 
                     :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                     :translations_upload_id=> translations_upload_id, 
                     plural: plural_value(plurals, plural_key)
                     )
            #object_persisted = true
            msg = "overwrite: persisted anyway because translation blank: " + msg_data
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
            #We update where the translation is nil anyway
            object.update_attributes!(
                    :translation=> translation, 
                    :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                    :translations_upload_id=> translations_upload_id, 
                    plural: plural_value(plurals, plural_key)
                    )
            #object_persisted = true
            msg = "Overwrite: persisted anyway because tranlation blank: translation: " + msg_data
            Rails.logger.info msg
            puts msg
            object.written = true
            return object
          else
            msg = "Cancelled because of duplicate dot_key_code: data " + msg_data
            Rails.logger.info msg
            puts msg
            
            ret_val = Translation.new(
                    :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                    :dot_key_code=> dkc, :translation=>translation, 
                    :translations_upload_id => translations_upload_id, 
                    plural: plural_value(plurals, plural_key)
                    )
            ret_val.errors.add(:dot_key_code, I18n.t("messages.write_file_to_db.cancel", {:language=> language, :dot_key_code => object.dot_key_code}))
            ret_val.written = false
            return ret_val
          end 
        else
          msg = "Invalid value for overwrite condition. Invalid value = " + overwrite + ". Data is " + msg_data
          object.errors.add(:base, msg)
          object.written = false
          return object
        end #overwrite condition 
     end #def

=begin
 If the code is a new one for this calmapp_version_translation_language then write the translation with this method
=end       
  def self.do_new_condition(dkc, translation, calmapp_versions_translation_language, translations_upload_id, msg_data, plurals)
    msg = "Write new translation: " + msg_data
    puts msg
    Rails.logger.info msg
    plural_key = full_key(calmapp_versions_translation_language, dkc)
    #plural_val = plural_value(plural_key)
    
    ret_val = Translation.new(
         :cavs_translation_language_id => calmapp_versions_translation_language.id, 
         :dot_key_code=> dkc, :translation=>translation, 
         :translations_upload_id => translations_upload_id, 
         plural: plural_value(plurals, plural_key)#((en?(plural_key)) ?  (plurals[plural_key]) : nil )
         )
    
    ret_val.save!       
    ret_val.written = true
    return ret_val
  end    
  
  def self.en? full_key
    return full_key[0..2] == 'en.'
  end
  
  def self.plural_value(plurals, full_key)
    return plurals[full_key] if en?(full_key)
    return nil
  end  
end