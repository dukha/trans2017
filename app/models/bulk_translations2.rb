=begin
 This class is an overflow class for writing bulk translations (from files) Translation   
=end
class BulkTranslations2
=begin
 plural forms come in arrays like ['one', 'other'] or ['one', 'few', 'many', 'other']
 Given a dot key code which is identified adot_key_code ilikes a plural, this method will save all appropriate plurals
 for this dot key code, without translation
 
 @param dot_key_code
 @param cavtl The relevant calmapp_version_translation_language object for this dot key  
 @return array with saved plurals
=end    
  def self.translations_to_db_from_file hash, translation_upload_id, calmapp_versions_translation_language, overwrite#, plurals
    keys =  hash.keys
    puts "Number of keys in hash to be written " + keys.count.to_s
    count=0
    translation = nil
    language = calmapp_versions_translation_language.translation_language.iso_code
    plural_same_as_en = calmapp_versions_translation_language.translation_language.plurals_same_as_en?()
    previous_translation = nil
    binding.pry if hash.keys.include?("restrict_dependent_destroy")
    unless keys.empty?
      keys.each do |k|  
        
        translation = translation_to_db_from_file(k, hash[k], translation_upload_id, calmapp_versions_translation_language, plural_same_as_en, overwrite)#, plurals)    
        
        if translation.nil? then  
          #binding.pry
          #this is the situation where the translation language is not en and the english translation for the saem dot key does not exist
          next if k != keys.last
          return previous_translation unless previous_translation.nil?
          return  create_new_translation_for_error_return("Processing keys: one was nil: not the last, but previous translaton was also nil", calmapp_versions_translation_language.translation_language.name )
        end  
        if  translation.errors.count > 0 then
          return translation
        end
        if translation.written then
          previous_translation = translation
          count += 1
        end   
      end # do
    else
      return create_new_translation_for_error_return("No keys present to write to database", calmapp_versions_translation_language.translation_language.name )
    end #keys empty  
    msg = "keys written to db >= " + count.to_s
    puts msg
    Rails.logger.info msg
    #msg =  "Different types of plurals in different langauges mean that the above number is not exact"
    #puts msg
    #Rails.logger.info msg
    return translation unless translation.nil?
    return create_new_translation_for_error_return("Something has gone wrong with writing keys to the database. At the end of " + "translations_to_db_from_file." +  " All keys are processed but still continued to the bottom.", calmapp_versions_translation_language.translation_language.name )
  end
  
  def self.create_new_translation_for_error_return message, language_name
    newie = Translation.new
    newie.errors[:base] << ( message + " for upoload of " + language_name) 
    return newie
  end
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
  def self.translation_to_db_from_file(key, translation,translations_upload_id, calmapp_versions_translation_language, plural_same_as_en, overwrite) 
    split_hash= split_full_dot_key_code key
    language = calmapp_versions_translation_language.translation_language.iso_code
    dkc = split_hash[:dot_key_code]
    is_plural = "unknown"
    msg_data = trans_msg_data(((translation.is_a? String) ? translation : translation.to_s), language, dkc )
    record_arr =   Translation.where{dot_key_code == my{dkc}}.where{cavs_translation_language_id == my{calmapp_versions_translation_language.id}}
    is_new_record = (not record_arr.exists?)
    existing_translation_attr = nil
    
    if not is_new_record
      existing_translation_attr = record_arr.select(translation)
    end
    en_translation_exists = nil
    if language != 'en' then 
      #puts "lang is not en"
      en_translation_exists = Translation.english_translation_exists(calmapp_versions_translation_language, dkc)
      #if key.include? "date.abbr_day_names" 
        #Rails.logger.info("date.abbr_day_names" + en_translation_exists.to_s)
      #end
      #binding.pry if key.include?("restrict_dependent_destroy") #bbbbbbbbbbbbb
      if en_translation_exists 
        msg = "English translation exists for " + msg_data
      else # no en trans
        
        #we may find that a plural has vgotten by the yaml parser.
        # We check again to see if we can shorten the dkc because it is a plura        
        plurals = calmapp_versions_translation_language.translation_language.plurals
        #if (dkc.include?(".header")) #&& (calmapp_versions_translation_language.translation_language.iso_code == 'ja')
      
        #end
        split_dkc = dkc.split('.')
        test_dkc = split_dkc[0..split_dkc.length-2].join('.')
                   #We check the new test_dkc
        en_translation_exists = Translation.english_translation_exists(calmapp_versions_translation_language, test_dkc)
        if en_translation_exists
           msg_data = trans_msg_data(translation, language, test_dkc)
           msg = "English translation exists for " + msg_data
        end
        #if key.include? "date.abbr_day_names" 
          #Rails.logger.info("date.abbr_day_names now " + en_translation_exists.to_s)
        #end
        #binding.pry if key.include?("restrict_dependent_destroy")#bbbbbbbbbb
        if plurals.include?(split_dkc.last) # en_translation_exists
          #We have a plural that has nothing written to the db yet
          dkc = test_dkc
          is_plural = true          
          # build the plurals has with just 1 value and the rest of the values blank 
          if is_new_record
            plurals.delete(split_dkc.last)
            plurals_hash = { split_dkc.last => translation}
            plurals.each{|p| plurals_hash[p] = '' }
            translation = ActiveSupport::JSON.encode(plurals_hash)
          else
            if JSON.is_json? existing_translation_attr
              hash = ActiveSupport::JSON.decode(existing_translation_attr)
            end
            hash[split_dkc.last] = translation 
            translation = ActiveSupport::JSON.encode(hash)
          end 
        else # plurals don't include last so there is no valid en key
          msg = "English Dot key Code does not exist. Checked for accidental plural " + msg_data
          Rails.logger.error("Data Error in English " + msg)
          #We will continue processing here so return nil
          return nil
          #return unsaved_record(dkc, calmapp_versions_translation_language, translation, translations_upload_id, msg_data, msg)
        end #check plurals 
      end # en exists 
    end #lang is not en
      object = nil  
      object = record_arr.first if not is_new_record
      msg_data = trans_msg_data(((translation.is_a? String) ? translation : translation.to_s), language, dkc)
      if not object.nil? then
        msg  = "Calling overwrite : " + msg_data
        Rails.logger.debug msg
        puts msg
        return do_overwrite_condition(dkc, translation, calmapp_versions_translation_language, translations_upload_id, overwrite, object,  msg_data, plurals)
      else # object does not exist in db
        # if not overwrite or match language and keys count=0 then this code executes
        msg = "Calling new condition : " + msg_data
        Rails.logger.debug msg
        puts msg   
        return do_new_condition(dkc, translation, calmapp_versions_translation_language, translations_upload_id, msg_data, plurals)
      end # object is nil
  end  #def
  
=begin
  A record must be returned. Returning an unsaved record is the best way of allowing the return of the saved record
=end   
  def self.unsaved_record(dkc, calmapp_versions_translation_language,translation, translations_upload_id, msg_data, message)
    
    msg = "English translation does not exist so not saving " + message + " " + msg_data
    puts msg
    Rails.logger.info msg
    ret_val = Translation.new(
      :cavs_translation_language_id => calmapp_versions_translation_language.id, 
      :dot_key_code=> dkc, 
      :translation=>translation, 
      :translations_upload_id => translations_upload_id)
    ret_val.errors.add(:base, msg)
    return ret_val
  end
  
=begin
 Splits a full_dot_key_code into language and dot_key_code (without language)
 #return hash keyed by ":language" and ":dot_key_code" 
=end  
  def self.split_full_dot_key_code full_dot_key_code
    code_array = full_dot_key_code.split(".") 
    return {:language=> code_array[0], :dot_key_code=> code_array[1..(code_array.length-1)].join(".")}
  end
  
=begin
 object is already persisted object 
=end   
  def self.do_overwrite_condition(dkc, translation, calmapp_versions_translation_language, translations_upload_id, overwrite, object,  msg_data, plurals)
    #plural_key = Translation.full_key(calmapp_versions_translation_language, dkc)
    #if dkc.include? ".header"
  
    #end
   
    if JSON.is_json?(translation)
      t_json = translation
      no_json =  ActiveSupport::JSON.decode(translation)
    else
      t_json = ActiveSupport::JSON.encode(translation)
      no_json = translation
    end
    if JSON.is_json?(object.translation)
      tester = ActiveSupport::JSON.decode(object.translation)
    else
      tester = object.translation
    end
    #binding.pry if (object.translation.is_a?(String) && object.translation.include?("other"))
    if overwrite == Translation.Overwrite[:all] then
            if tester != translation then
              b = object.update_attributes!(
                         :translation=> t_json, 
                         :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                         :translations_upload_id=> translations_upload_id,   
                         )
              #translation = translation.to_json
              msg = "Object persisted: old translation: " + object.translation + " replaced with new translation: " + msg_data             
            else
               msg = "Object to be persisted is the same as already stored: " + msg_data
            end
            Rails.logger.info msg
            puts msg  
            object.written = true
            return object
        elsif overwrite == Translation.Overwrite[:continue_unless_blank] then
          #if object.translation.nil? then 
          if tester.blank?
            #We update where the translation is nil anyway
            #binding.pry if (translation.is_a?(String) &&  object.dot_key_code.include?('distance_in_words'))
            #binding.pry if object.dot_key_code.include?('distance_in_words')
            b = object.update_attributes!(
                     :translation=> t_json, 
                     :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                     :translations_upload_id=> translations_upload_id, 
                     )
            msg = "overwrite: persisted anyway because translation blank: " + msg_data
            Rails.logger.info msg
            puts msg
            object.written = true
          elsif (tester.is_a?(TrueClass) || tester.is_a?(FalseClass))
              object.update_attributes!(
                     :translation=> ActiveSupport::JSON.encode(t_json), 
                     :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                     :translations_upload_id=> translations_upload_id, 
                     ) 
             msg = "overwrite: persisted anyway because boolean cannot be blank: " + msg_data
            Rails.logger.info msg
            puts msg
            object.written = true 
          elsif ((tester.is_a? Array)  && has_empty_some_values(tester))  
            #This is a case of hash for translation e.g. plural
            #binding.pry
            i=0
            new_translation = []
            tester.each{|v|
                if no_json[i].blank?
                   new_translation[i] = tester[i]
                else
                   new_translation[i] = (tester[i].blank? ? no_json[i] : tester[i])
                end
                i += 1 
            }
            #binding.pry 
            object.update_attributes!(
                     :translation=> ActiveSupport::JSON.encode(new_translation), 
                     :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                     :translations_upload_id=> translations_upload_id, 
                     ) 
             msg = "overwrite: persisted anyway because (part of) translation blank: " + msg_data
            Rails.logger.info msg
            puts msg
            object.written = true        
          elsif ((tester.is_a? Hash) && has_empty_some_values(tester))
            # This is case of an array for translation e.g days of week
            #binding.pry
            new_translation = {}
            tester.each{ |k,v|
              if no_json[k].blank? 
                new_translation[k] = tester[k]
              else
                new_translation[k] = (tester[k].blank? ? no_json[k] : tester[k])  
              end 
            }
            #binding.pry
            object.update_attributes!(
                     :translation=> ActiveSupport::JSON.encode(new_translation), 
                     :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                     :translations_upload_id=> translations_upload_id, 
                     ) 
             msg = "overwrite: persisted anyway because (part of) translation blank: " + msg_data
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
          if (tester.is_a? String && tester.blank?) || all_empty?(tester) 
            #We update where the translation is nil anyway
            object.update_attributes!(
                    :translation=> t_json, 
                    :cavs_translation_language_id => calmapp_versions_translation_language.id, 
                    :translations_upload_id=> translations_upload_id, 
                    #plural: plural_value(plurals, plural_key)
                    )
            msg = "Overwrite: persisted anyway because (part of) tranlation blank: translation: " + msg_data
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
  def self.has_empty_some_values tester
    if tester.is_a? Array then
      tester.each{|v|
        if v.blank?
          return true
        end  
      }
       return false
    end
   
    
    if tester.is_a? Hash then
      tester.each{|k,v|
        if v.blank?
          return true
        end  
      }
      return false
    end
    # return false here as boolean cannot be blank
    return false if (tester.is_a?(TrueClass) || Tester.is_a?(FalseClass))
    return ! tester.blank?
  end
=begin  
  def self.array_has_empty_some_values array
    if array.is_a? Array then
      array.each{|v|
        if v.blank?
          return true
        end  
      }
    end
    return false
  end
=end  
  def self.all_empty? tester
    if tester.is_a?(Array)
      tester.each{|v|
        if ! v.blank?
          return true
        end  
      }
      return false
    elsif tester.is_a? Hash
      if tester.is_a? Hash then
      tester.each{|k,v|
        if ! v.blank?
          return true
        end  
      }
      return false
    end
      return tester.blank?
    end
  end
=begin
 If the code is a new one for this calmapp_version_translation_language then write the translation with this method
=end       
  def self.do_new_condition(dkc, translation, calmapp_versions_translation_language, translations_upload_id, msg_data, plurals)
    msg = "Write new translation: " + msg_data
    puts msg
    Rails.logger.info msg
   #binding.pry if dkc.include?('number.format.strip_insignificant_zeros')
    #binding.pry if dkc.include?('significant')#'number.format.strip_insignificant_zeros'
    if JSON.is_json?(translation)
      t_json = translation
    else
      t_json = ActiveSupport::JSON.encode(translation)
    end
    #binding.pry if dkc.include? 'significant'
    ret_val = Translation.new(
         :cavs_translation_language_id => calmapp_versions_translation_language.id, 
         :dot_key_code=> dkc, 
         :translation=>t_json, 
         :translations_upload_id => translations_upload_id, 
         )  
    ret_val.save!       
    ret_val.written = true
    return ret_val
  end        
end