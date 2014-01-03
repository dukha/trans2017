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
      #check_box_tag("profile[roles][]", role, profile.roles.include?( role), :class=>"profilecheckbox")
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
  
  
=begin from page
 <li class='check_boxes input optional' id='calmapp_calmapp_versions_attributes_0_translation_languages_input'>
     <fieldset class='choices'>
        <legend class='label'>
           <label>Translation languages</label>
         </legend>
         <input id='calmapp[calmapp_versions_attributes][0]_translation_languages_none' name='calmapp[calmapp_versions_attributes][0][translation_language_ids][]' type='hidden' value='' />
         <ol class='choices-group'>
           <li class='choice'>
           <label for='calmapp_calmapp_versions_attributes_0_translation_language_ids_7'>
             <input checked='checked' id='calmapp_calmapp_versions_attributes_0_translation_language_ids_7' name='calmapp[calmapp_versions_attributes][0][translation_language_ids][]' type='checkbox' value='7' />Chinese</label>
           </li>
           
           <li class='choice'>
             <label for='calmapp_calmapp_versions_attributes_0_translation_language_ids_9'>
               <input id='calmapp_calmapp_versions_attributes_0_translation_language_ids_9' name='calmapp[calmapp_versions_attributes][0][translation_language_ids][]' type='checkbox' value='9' />Chinese(Malaysia)</label>
           </li> 
=end
  
=begin from profiles
  def layout_check_boxes profile
    html =''
    rows_data= collect_roles_in_groups
    #puts "bbbb " + collect_roles_in_groups.to_s
    if ! rows_data.empty? then
      html << "<table>"
      rows_data.each { |array|
        next if array.empty?
        html << "<tr class = '" + cycle('dataeven', 'dataodd') + "' >"
        
        html << "<td class='profilerowheader'>"
        if array == rows_data.last then
          html<< t("roles.miscellaneous")  
        else
          sym = first_not_nil_element_array(array) 
          next if sym.nil?        
          arr=sym.to_s.split("_")
          if arr.length >2 then
            translation_code = "roles." + arr[0..(arr.length)-2].join("_")
            #html << t("roles." + arr[0..(arr.length)-2].join("_"))
          else
            translation_code = "roles." + arr[0]
          end  
          html << t(translation_code)
          puts translation_code
        end #last

        html << "</td>"
        array.each{ |role|
          if role.nil? then
            next
          end
          html << "<td class='profilecheckboxtd'>"
          html << check_box_tag("profile[roles][]", role, profile.roles.include?( role), :class=>"profilecheckbox")
          #binding.pry
          if array==rows_data.last then
            html << label_tag(role, t("roles." + role.to_s)) #t("."+role.to_s))
          else
            #if role.nil?
              #binding.pry
            #end
            label = role.to_s.split("_").last
            #if label.nil?
              #binding.pry
            #end
            html << label_tag(role, t("roles.actions." + label))
          end
          html << "</td>" 
        }  # end each role
        html << "</tr>\n"
        }
        end
        html<< "</table>"
      #binding.pry
        return html.html_safe
    end #def layout
=end
end # module