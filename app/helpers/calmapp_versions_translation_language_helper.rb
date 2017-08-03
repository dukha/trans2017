module CalmappVersionsTranslationLanguageHelper
  def selection_admin_publishing_dbs calmapp_versions_translation_language
    dbs = calmapp_versions_translation_language.redis_databases
    if dbs.count == 0 then
      return ''
    else  
      #binding.pry
      html = "<select id = " + selectbox_id(calmapp_versions_translation_language) + "' name = 'redis_database_id' class = 'cavtl' >"
      html << "\n<option value = ''></option>" 
      dbs.each{ |db|  
        html << ("\n<option value='" + db.id.to_s + "'>" + db.description + "</option>")  
      }
      html << ("\n</select>")
    end
    
    return html.html_safe
  end
  
  def selectbox_id(calmapp_versions_translation_language)
    return "'cavtl'" + "%03d" % calmapp_versions_translation_language.id + " "
  end
  
  def selection_production_dbs calmapp_versions_translation_language
    dbs = calmapp_versions_translation_language.production_redis
    if dbs.count == 0 then
      return ''
    else  
      html = "<select id =" + selectbox_id(calmapp_versions_translation_language)  + "' name = 'redis_database_id' >"
      html << "\n<option value = ''></option>" 
      dbs.each{ |db|  
        html << ("\n<option value='" + db.id.to_s + "'>" + db.description + "</option>")  
      }
      html << ("\n</select>")
    end
    
    return html.html_safe
  end
  def not_en?(cavtl)
    
    return cavtl.translation_language != TranslationLanguage.TL_EN 
  end
  
  def permission_ok_for_en? cavtl
    return current_user.sysadmin? || current_user.developer_cavs_tls.include?(cavtl)
  end
  
  def redis?(cavtl)
    return ! cavtl.calmapp_version_tl.translators_redis_database.nil?
  end
  
  def user_has_language?(cavtl)
    return current_user.translator_cavs_tls.include?(cavtl)
  end
  
  
  
  def user_has_language_or_sysadmin cavtl
    return true if user_has_language?(cavtl)
    return current_user.sysadmin?#profiles.include?(Profile.where{name == 'sysadmin'}.first)  
  end
  
  def has_translatorpublish_role?
    has_role? :calmapp_versions_translation_languages_translatorpublish
  end
  
  def has_translator_to_production_role?
    return has_role? :calmapp_versions_translation_languages_translatorproductionpublish
  end
end