module CalmappVersionsTranslationLanguageHelper
  def selection_publishing_dbs calmapp_versions_translation_language
    dbs = calmapp_versions_translation_language.redis_databases
    if dbs.count == 0 then
      return ''
    else  
      html = "<select id = 'cavtl" + calmapp_versions_translation_language.id.to_s + "' name = 'redis_database_id' >"
      html << "\n<option value = ''></option>" 
      dbs.each{ |db|
        #html << ("\n<option value='" + db.id.to_s + "'>" + db.description + "</option>")  
        html << ("\n<option value='" + db.id.to_s + "'>" + db.description + "</option>")  
      }
      html << ("\n</select>")
    end
    #puts "xxx: " + html
    return html.html_safe
  end
end