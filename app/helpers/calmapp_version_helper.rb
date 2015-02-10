module CalmappVersionHelper
  include TranslationsHelper
  include I18n
  def layout_checkboxes calmapp_version
    languages = TranslationLanguage.order("name ASC").all
    #html = "<li class='check_boxes input optional' id='calmapp_calmapp_versions_attributes_0_translation_languages_input'>
    html = open("li", {class: "'check_boxes input optional'", "id" => "'calmapp_calmapp_versions_attributes_0_translation_languages_input'"}) 
    html = html + "\n" + open( "fieldset", {:class=> "'choices'"})
    html = html + "\n" + open("legend", {class: "'label'"}  )
    html = html + "\n" + open("label") + 
                I18n.t($ARM + ".translation_language.one") + 
                close("label")
                close("legend") 
    count= 0
    languages.each do |l|            
      html = html + "\n" + open("input", {id: "'calmapp[calmapp_versions_attributes][" + count.to_s + "]_translation_languages_none'"})
      
      count += 1
    end
    return html
  end
  
  def close tag
    "</" +tag +">"
  end
  
  def open tag, options = {}
    keys = options.keys
    html = "<" +tag
    keys.each do |k|
      html = html + " " + k.to_s + " = " + options[k]
    end    
    html +">"
  end
  
end # module