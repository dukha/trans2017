=begin
 This Module is the helper for  views/translations/* 
 TranslationHelper  is a help for the application to access translations that already exist.
=end
module TranslationHelper
=begin
 #return true Use best_in_place as editor
 @return false Display as plain text  
=end
  def best_in_place?(translation)

    #translation that is passed is only a query ressult: We need to get the real object for the next line
    return false if Translation.find(translation.id).is_plural?#is_plural?(translation)
    return true if ( translation.attributes["editor"].nil?) or 
                editor_date_time_select?(translation.attributes) or editor_number_select?(translation.attributes)
    return false  
  end
=begin  
  def is_plural?(translation)
    t = Translation.find(translation.id)
    return t.is_plural?
    
  end
=end
=begin
 Sets html attributes for the editor control in best in place 
=end  
  def input_text? attrs
    return (:input  ==  input_control(attrs))
  end
  def html_attrs(object_attrs)
    input = input_control(object_attrs)
     if  input == :select  
       size = '8'
     elsif input == :boolean then
       size = 2  
     else
       size = '40'
     end
     retVal =  { :placeHolder => "Click to translate", :size=> size} 
     return retVal
   end  
=begin
 @return the correct input control for best in place editing 
=end   
   def input_control(attrs)
     #binding.pry
       if (not attrs["en_translation"].nil?) && attrs["en_translation"].length  > 40 && attrs["editor"].nil? then
         return :textarea
       elsif attrs["editor"] == "date_format" then
         return :select
       elsif attrs["editor"] == "time_format" then  
         return :select
       elsif attrs["editor"] == "datetime_format" then  
         return :select
       else
         #boolean
         if JSON.is_json? attrs["en_translation"]
           en = ActiveSupport::JSON.decode(attrs["en_translation"])
         else
           en =   attrs["en_translation"]
         end
         if en == 't' || en == 'f' || en == true || en == false
           return :boolean
         end  
       end
       return :input
   end
=begin
  @return true if the correct editor is a date_format or a time format editor or a datetime format editor editor 
=end   
   def editor_date_time_select? attrs
     return %w(date_format time_format datetime_format decimal_format).include? attrs['editor']
   end
   
   def editor_number_select? attrs
     return %w(decimal_format).include? attrs['editor']
   end

=begin
  Formats the english transation on the index
=end   
   def format_english attributes#, plural 
     en = attributes["en_translation"]
     en =  ActiveSupport::JSON.decode(en) if JSON.is_json?(en) 
     return date_format_example(en) if editor_date_time_select?(attributes)  
     return "<i>[This plural not used in English]</i>".html_safe if attributes["en_translation"].nil?
     return "<i>[Not used in English, so left blank. It may be left blank in your language too.] </i>".html_safe if attributes["en_translation"].blank?
     
     special_structure = attributes["special_structure"]
     return format_noneditable(en, special_structure)
   end
   
   def format_readonly_translation attributes
     return date_format_example(attributes["en_translation"], attributes["iso_code"]) if editor_date_time_select?(attributes)
     return format_noneditable(attributes["translation"], attributes["special_structure"])   
   end
   
   def format_noneditable translation_not_json, special_structure
     #binding.pry
     #object = translation
     #object = ActiveSupport::JSON.decode(translation) if JSON.is_json?(translation)
     if  translation_not_json.is_a?(Hash) && (special_structure == Translation::TRANS_PLURAL)   
       html = "<table>"
       translation_not_json.each{|k, v|
         html = html + "<tr><td>" + k + ": "  + v + "</td></tr>" 
       }
       html = html + "</table>"  
       return html.html_safe
     elsif translation_not_json.is_a?(Array) && 
            (special_structure == Translation::TRANS_ARRAY_13_NULL || 
                special_structure == Translation::TRANS_ARRAY_7 ||
                special_structure == Translation::TRANS_ORDER_ARRAY)
       html = "<table>"
       translation_not_json.each{ |e|
         if e.nil?
           next
         end
         html = html + "<tr><td>" + e.to_s + ((e == translation_not_json.last) ? "" : ", ") + "</td></tr>"
         }
         html = html + "</table>"
         return html.html_safe
     else
         translation_not_json = true.to_s if translation_not_json == 't' 
         translation_not_json = false.to_s if translation_not_json == 'f' 
       return translation_not_json.to_s.html_safe
     end #if..elsif
     
   end
=begin
 #return the sample date for display of date and datetime formats 
=end   
   def example_date
     return Date.new(2007,11,29)
   end
=begin
 #return the sample time for display of time formats 
=end    
   def example_time
     return Time.new(2007,11,29,15,25,0)
   end
=begin
 @return the sample date formatted according to the Englsih translation 
=end   
   def date_format_example translation, iso_code ='en'
     return example_date.strftime(translation) if iso_code == 'en'
     begin
       return l(translation, iso_code)
     rescue I18n::InvalidLocale  
       return example_date.strftime(translation)
     end
   end
=begin
  
=end   
   def translated_full_abbrev_day_month(date, iso_code, version_id)
     dow = date.wday
     month = date.month
     days_abbrev = Translation.single_lang_translations_arr(iso_code,version_id).where{dot_key_code ==  "date.abbr_day_names"}.first.translation  
     day_abbrev = ActiveSupport::JSON.decode(days_abbrev)[dow]
     days_full = Translation.single_lang_translations_arr(iso_code,version_id).where{dot_key_code ==  "date.day_names"}.first.translation
     day_full = ActiveSupport::JSON.decode(days_full)[dow]
     months_abbrev = Translation.single_lang_translations_arr(iso_code,version_id).where{dot_key_code ==  "date.abbr_month_names"}.first.translation
     month_abbrev = ActiveSupport::JSON.decode(months_abbrev)[month]
     months_full = Translation.single_lang_translations_arr(iso_code,version_id).where{dot_key_code ==  "date.month_names"}.first.translation
     month_full = ActiveSupport::JSON.decode(months_full)[month]
     result = {month_full: month_full, month_abbrev: month_abbrev, day_full: day_full, day_abbrev: day_abbrev}.with_indifferent_access  
   end

=begin
 @return the correct collection of formats for date, datetime and time select controls
=end   
   def collection? attrs 
     if input_control(attrs) == :select then
       iso_code = attrs["iso_code"]
       if attrs["editor"] == "date_format" then
         date = example_date
         return short_date_collection(date, iso_code, attrs["version_id"]) if attrs["dot_key_code"] == 'date.formats.short'
         return default_date_collection(date, iso_code, attrs["version_id"]) if attrs["dot_key_code"] == 'date.formats.default'
         return long_date_collection(date, iso_code, attrs["version_id"]) if attrs["dot_key_code"] == 'date.formats.long'
       elsif  attrs["editor"] == "datetime_format" then  
         datetime =  example_date                    
         ret_val =  datetime_collection(datetime, iso_code, attrs["version_id"])  if attrs["dot_key_code"] == 'datetime.formats.course_form'
         return ret_val
       elsif attrs["editor"] == "time_format" then
         time = example_time
         return short_time_collection(time) if attrs["dot_key_code"] == 'time.formats.short'
         return default_time_collection(time) if attrs["dot_key_code"] == 'time.formats.default'
         return long_time_collection(time) if attrs["dot_key_code"] == 'time.formats.long'  
       end
     else
       return {}      
     end  # input select
   end #def     

=begin
 @return the name of the special editor (outside best in place) 
=end     
   def special_editor_name(attrs)
     return "plural" if attrs["special_structure"] == Translation::TRANS_PLURAL
     return attrs["editor"] if not attrs["editor"].nil?
     return"bip"
   end 


=begin
 Prepares a Date or Datetime for display for the user to select a format. 
 The date must  have day of week and month in the correct (translating) language. 
 @param strf The format of the date
 @param date The display date
 @param translation_language_hash a hash containing the correct day of week and months for the language 
 @param en_hash A hash containing the English day of week and month to be substituted
 @return the date formatted in the translation language
=end  
   def localised_date(strf, date, translation_language_hash, en_hash)
     result = date.strftime(strf)
     # These gsubs below must be done in the order of full before abbrev
     result.gsub!(en_hash["day_full"], translation_language_hash["day_full"])
 
     result.gsub!(en_hash["month_full"], translation_language_hash["month_full"])
     result.gsub!(en_hash["day_abbrev"], translation_language_hash["day_abbrev"])
     result.gsub!(en_hash["month_abbrev"], translation_language_hash["month_abbrev"])
     return result
   end
=begin
 Puts in the checked property for an input type radio according to default or what is in params.
 @todo make further generic by making default_value a param
 @param button_value the value of the value property in the input tag.
 @param param_value the value for this attribute that comes in the response
 @ return a phrase to indicate that the input is checked or not... 
=end   
   def initialise_selection_mode_radio_buttons(button_value, param_value)
 
     default_value = "all"
     checked_phrase = "checked = \"true\"".html_safe
     if param_value.nil? && default_value == button_value then
       return   checked_phrase
     elsif param_value == button_value then
       return checked_phrase
     else
       return ''
     end     
   end
=begin
 @param form is the formtastic form object
 @param q_object is the original query object. It may not have all attributes but has extra atrributes becasue of the join in the query 
=end   
   def translation_index_form_standard_html1 form, q_object, display = false
      
          if q_object.attributes['editor'].blank?
            if q_object.attributes["special_structure"] == Translation::TRANS_PLURAL
              editor = 'plural'
             else
               editor = ''
             end
          else
            editor =  q_object.attributes['editor']
          end  
          html = form.text_field(:translation, :id => "translation_translation", :style=> "" + ((display) ? "display: inline; " : "display:none; ")) 
          html = html + "\n" + text_field_tag("editor",  "#{editor}", :style=> "" + ((display) ? "display: inline; " : "display:none; "))
          html = html + "\n" + text_field_tag("original_translation",  "#{form.object.attributes['translation']}", 
                                            :style=> "" + ((display) ? "display: inline; " : "display:none; "), :id => "original-translation")
          html = html + "\n" + editor_text_field(editor)
          html = html + "\n" + text_field_tag("dot_key_code",  "#{form.object.attributes['dot_key_code']}", :style=>"" + ((display) ? "display: inline; " : "display:none; "))
      
           #((q_object.attributes["iso_code"] == 'en') ? ("#{q_object.attributes['en_translation']}") : ("#{q_object.attributes['en_translation']}"))
          html = html + "\n" + english_text_field(q_object.attributes)
          return html.html_safe
   end
   
   def  editor_text_field editor_name
     return text_field_tag("editor-name",  "#{editor_name}", :style=> "" + ((display) ? "display: inline; " : "display:none; "))
   end
   
   def english_text_field(attrs)
     en = "#{attrs['en_translation']}"
     return  text_field_tag("english",  en, :style=> "" + ((display) ? "display: inline; " : "display:none; "))
   end  
=begin
 @param form is the formtastic form object
 @param q_object is the original query object. It may not have all attributes but has extra atrributes becasue of the join in the query 
=end   
   def translation_index_form_standard_html2 form, q_object, display = false
     html = "<div id ='special-editor-hints' style= '" + "" + ((display) ? "display: inline; " : "display:none; ") + "' >" + t($FH + 'translation.special_editor.' + 
     special_editor_name(q_object.attributes).downcase) + "</div>"
     html = html + "<br>" 
     html = html + form.submit(t($FA + 'save'), :id=>'ok-special-editor', :style=> "" + ((display) ? "display: inline; " : "display:none; "))
     html = html + button_tag(t($FA +  'cancel'), :type=>'button', :id=> 'cancel-special-editor', :style => "" + ((display) ? "display: inline; " : "display:none; ")) 
     return html.html_safe
   end
   def plural_editing_table attrs, display = false
     html = "<table id = 'plural-editor', class = 'plural-editor' style = '" + "" + ((display) ? "display: inline; " : "display:none; ")  + "'>"#'background-color: green;'>"
     
     begin
       t = ActiveSupport::JSON.decode(attrs["translation"])
     rescue StandardError => e
   
       puts e.message
       raise
     end  
     
     if t.is_a? String
       other = t
       t = {"other" => t}
   
     end
     if t.is_a? Hash then
      #binding.pry #if attrs.dot_key_code.include?("restrict")
       t.each do |k,v|
         html = html + "<tr><td >" + k + "</td><td >"
         v = '' if v.nil? #mplnils
         if v.length <= 60 then       
           html = html + text_field_tag( k, v, {:id=> attrs["dot_key_code"]  + "." + k, :size=>35, :name =>"translation_plural[" + k + "]"}) 
         else
           html = html + text_area_tag(k,v, {:id=> attrs["dot_key_code"]  + "." + k, :cols=>35, :name =>"translation_plural[" + k + "]" })
         end
         html = html + "</td></tr>"  
       end # each
     end #hash
     html = html +  "</table>"
 
     return html.html_safe
   end  
   
=begin
 For use in views 
=end   
    def plural_translation_static_text(translation)
      TranslationHelper.plural_translation_static_text(translation)
    end
    
=begin
 Use this if you want to call this in the controller 
=end 
   def self.plural_translation_static_text(translation)
     if JSON.is_json?(translation)
       t = ActiveSupport::JSON.decode(translation)
     else
       t = translation
     end
     if t.nil?
       
     end
     html = "<table id = 'plural-viewer'>"
     
     if t.is_a? Hash then
   
       
       t.each{|k, v|
         #binding.pry if k.nil? || v.nil?  #mplnils
         v = '' if v.nil?
         html = html + "<tr><td><b>" + k + "</b>: "  + v + "</td></tr>" 
       }
      
     elsif t.is_a? String
       html = html + "<tr><td>" + t + "</td></tr>"
     end
      html = html + "</table>"  
       return html.html_safe
   end
   
   def users_cavs_tls(user)
     arr = user.all_cavtl_permissions.to_a#@translator_cavs_tls + current_user.developer_cavs_tls + current_user.administrator_cavs_tls 
     arr.sort!
     return arr.uniq
   end   
   private
=begin
 Contains all the    date formats for a drop down 
=end
     def short_date_collection date, iso_code, version_id
       language_hash = translated_full_abbrev_day_month(date, iso_code, version_id)
       en_hash =  translated_full_abbrev_day_month(date, 'en', version_id)                
       return  {"%-d %b" => localised_date("%-d %b", date, language_hash, en_hash),
               "%m/%d" => localised_date("%m/%d", date, language_hash, en_hash),
               "%d.%m.%Y" => localised_date("%d.%m.%Y", date, language_hash, en_hash),
               "%b%d日" => localised_date("%b%d日", date, language_hash, en_hash),
               "%e %b" => localised_date("%e %b", date, language_hash, en_hash),
               "%b %e." => localised_date("%b %e.", date, language_hash, en_hash),
               "%e.%m.%Y" => localised_date("%e.%m.%Y", date, language_hash, en_hash),
               "%d de %b" => localised_date("%d de %b", date, language_hash, en_hash),
               "%e. %b" => localised_date("%e. %b", date, language_hash, en_hash),
               "%e. %B" => localised_date("%e. %B", date, language_hash, en_hash),
               "%b %d" => localised_date("%b %d", date, language_hash, en_hash),
               "%d %b" => localised_date("%d %b", date, language_hash, en_hash),
               "%d de %B" => localised_date("%d de %B", date, language_hash, en_hash),
               "%d.%m.%y" => localised_date("%d.%m.%y", date, language_hash, en_hash),
               "%y-%m-%d" => localised_date("%y-%m-%d", date, language_hash, en_hash),
               "%m-%d-%Y" => localised_date("%m-%d-%Y", date, language_hash, en_hash),
               "%m/%d/%Y" => localised_date("%m/%d/%Y", date, language_hash, en_hash),
               "%d. %b" => localised_date("%d. %b", date, language_hash, en_hash)}         
     end
=begin
    Contains all the default data formats suitable for listing in a drop down
=end   
     def default_date_collection date, iso_code, version_id
       language_hash = translated_full_abbrev_day_month(date, iso_code, version_id)
       en_hash =  translated_full_abbrev_day_month(date, 'en', version_id)

       return {"%d %B %Y" => localised_date("%d %B %Y", date, language_hash, en_hash),
               "%d. %m. %Y" => localised_date("%d. %m. %Y", date, language_hash, en_hash),
               "%e. %Bta %Y" => localised_date("%e. %Bta %Y", date, language_hash, en_hash),
               "%d.%m.%Y" => localised_date("%d.%m.%Y", date, language_hash, en_hash),
               "%d/%m/%Y" => localised_date("%d/%m/%Y", date, language_hash, en_hash),
               "%d.%m.%Y." => localised_date("%d.%m.%Y.", date, language_hash, en_hash),
               "%Y.%m.%d." => localised_date("%Y.%m.%d.", date, language_hash, en_hash),
               
               "%Y-%m-%d" => localised_date("%Y-%m-%d", date, language_hash, en_hash),
               "%d-%m-%Y" => localised_date("%d-%m-%Y", date, language_hash, en_hash),
               "%Y/%m/%d" => localised_date("%Y/%m/%d", date, language_hash, en_hash)} 
     end
=begin
   Contains all the long date formats for a drop down 
=end   
     def long_date_collection date, iso_code, version_id
       language_hash = translated_full_abbrev_day_month(date, iso_code, version_id)
       en_hash =  translated_full_abbrev_day_month(date, 'en', version_id)

       return {"%Y年%b%d日" => localised_date("%Y年%b%d日", date, language_hash, en_hash),
               "%Y년 %m월 %d일 (%a)" => localised_date("%Y년 %m월 %d일 (%a)", date, language_hash, en_hash),
               "%Y. %B %e." => localised_date("%Y. %B %e.", date, language_hash, en_hash),
               "%Y %B %d" => localised_date("%Y %B %d", date, language_hash, en_hash),
               "%B %e, %Y" => localised_date("%B %e, %Y", date, language_hash, en_hash),
               "%e %B %Y" => localised_date("%e %B %Y", date, language_hash, en_hash),
               "%A %e. %Bta %Y" => localised_date("%A %e. %Bta %Y", date, language_hash, en_hash),
               "%Y. gada %e. %B" => localised_date("%Y. gada %e. %B", date, language_hash, en_hash),
               "%e. %B %Y" => localised_date("%e. %B %Y", date, language_hash, en_hash),
               "%d %B, %Y" => localised_date("%d %B, %Y", date, language_hash, en_hash),
               "%A, %d %B %Y" => localised_date("%A, %d %B %Y", date, language_hash, en_hash),
               "%Y年%m月%d日(%a)" => localised_date("%Y年%m月%d日(%a)", date, language_hash, en_hash),
               "%d. %B %Y" => localised_date("%d. %B %Y", date, language_hash, en_hash),
               "%d de %B de %Y" => localised_date("%d de %B de %Y", date, language_hash, en_hash),
               "%-d %B %Y" => localised_date("%-d %B %Y", date, language_hash, en_hash),
               "%d. %b %Y" => localised_date("%d. %b %Y", date, language_hash, en_hash),
               "%B %d, %Y" => localised_date("%B %d, %Y", date, language_hash, en_hash),
               "%a %e/%b/%Y" => localised_date("%a %e/%b/%Y", date, language_hash, en_hash),
               "%a %b-%e-%Y" => localised_date("%a %b-%e-%Y", date, language_hash, en_hash),
               "%a %b/%e/%Y" => localised_date("%a %b/%e/%Y", date, language_hash, en_hash),
               "%a %e-%b-%Y" => localised_date("%a %e-%b-%Y", date, language_hash, en_hash),
               "%d %B %Y" => localised_date("%d %B %Y", date, language_hash, en_hash)}
     end 
=begin
   Contains all the default datetime formats for a drop down 
=end   
     def datetime_collection datetime, iso_code, version_id
       language_hash = translated_full_abbrev_day_month(datetime, iso_code, version_id)
       en_hash =  translated_full_abbrev_day_month(datetime, 'en', version_id)            
=begin
       return {"%a %b-%e-%Y" => datetime.strftime("%a %b-%e-%Y", datetime, language_hash, en_hash),
               "%a %b/%e/%Y" => datetime.strftime("%a %b/%e/%Y", datetime, language_hash, en_hash),
               "%a %e-%b-%Y" => datetime.strftime("%a %e-%b-%Y", datetime, language_hash, en_hash)}
=end       
       return {"%a %b-%e-%Y" => localised_date("%a %b-%e-%Y", datetime, language_hash, en_hash),
               "%a %b/%e/%Y" => localised_date("%a %b/%e/%Y", datetime, language_hash, en_hash),
               "%a %e-%b-%Y" => localised_date("%a %e-%b-%Y", datetime, language_hash, en_hash)}
  
     end 
=begin
   Contains all the short datetime formats for a drop down 
=end   
     def short_time_collection time   
         return {"%d. %m. %H:%M" => time.strftime("%d. %m. %H:%M"),
             "%e %b %H:%M" => time.strftime("%e %b %H:%M"),
             "%b %e., %H:%M" => time.strftime("%b %e., %H:%M"),
             "%d/%m, %H:%M hs" => time.strftime("%d/%m, %H:%M hs"),
             "%d.%m.%Y., %H:%M" => time.strftime("%d.%m.%Y., %H:%M"),
             "%b%d日 %H:%M" => time.strftime("%b%d日 %H:%M"),
             "%d. %b ob %H:%M" => time.strftime("%d. %b ob %H:%M"),
             "%d %b %I:%M %p" => time.strftime("%d %b %I:%M %p"),
             "%e.%m. %H.%M" => time.strftime("%e.%m. %H.%M"),
             "%d %b, %H:%M" => time.strftime("%d %b, %H:%M"),
             "%d %b %H.%M" => time.strftime("%d %b %H.%M"),
             "%y/%m/%d %H:%M" => time.strftime("%y/%m/%d %H:%M"),
             "%d.%m. %H:%M" => time.strftime("%d.%m. %H:%M"),
             "%d de %b %H:%M" => time.strftime("%d de %b %H:%M"),
             "%b%d號 %H:%M" => time.strftime("%b%d號 %H:%M"),
             "%d %b %H:%M" => time.strftime("%d %b %H:%M"),
             "%d.%m.%y, %H:%M" => time.strftime("%d.%m.%y, %H:%M"),
             "%d. %B, %H:%M Uhr" => time.strftime("%d. %B, %H:%M Uhr"),
             "%y-%m-%d" => time.strftime("%y-%m-%d"),
             "%d %b %H:%M น." => time.strftime("%d %b %H:%M น."),
             "%e. %B, %H:%M" => time.strftime("%e. %B, %H:%M")}
             
     end
=begin
   Contains all the default time formats for a drop down 
=end   
     def default_time_collection time
              return {"%A, %d %b %Y ob %H:%M:%S" => time.strftime("%A, %d %b %Y ob %H:%M:%S"),
             "%A %e. %Bta %Y %H:%M:%S %z" => time.strftime("%A %e. %Bta %Y %H:%M:%S %z"),
             "%Y. gada %e. %B, %H:%M" => time.strftime("%Y. gada %e. %B, %H:%M"),
             "%Y年%b%d日 %A %H:%M:%S %Z" => time.strftime("%Y年%b%d日 %A %H:%M:%S %Z"),
             "%d %B %Y %H:%M:%S" => time.strftime("%d %B %Y %H:%M:%S"),
             "%a, %e %b %Y %H:%M:%S %z" => time.strftime("%a, %e %b %Y %H:%M:%S %z"),
             "%a, %d %b %Y %I:%M:%S %p %Z" => time.strftime("%a, %d %b %Y %I:%M:%S %p %Z"),
             "%d %B %Y %H:%M" => time.strftime("%d %B %Y %H:%M"),
             "%a %b %d %H:%M:%S %Z %Y" => time.strftime("%a %b %d %H:%M:%S %Z %Y"),
             "%A, %d. %B %Y, %H:%M Uhr" => time.strftime("%A, %d. %B %Y, %H:%M Uhr"),
             "%Y. %b %e., %H:%M" => time.strftime("%Y. %b %e., %H:%M"),
             "%a, %d %b %Y, %H:%M:%S %z" => time.strftime("%a, %d %b %Y, %H:%M:%S %z"),
             "%d. %B %Y, %H:%M" => time.strftime("%d. %B %Y, %H:%M"),
             "%Y/%m/%d %H:%M:%S" => time.strftime("%Y/%m/%d %H:%M:%S"),
             "%a %d. %B %Y %H:%M %z" => time.strftime("%a %d. %B %Y %H:%M %z"),
             "%A, %d de %B de %Y, %H:%Mh" => time.strftime("%A, %d de %B de %Y, %H:%Mh"),
             "%a %d %b %Y, %H:%M:%S %z" => time.strftime("%a %d %b %Y, %H:%M:%S %z"),
             "%A, %d de %B de %Y %H:%M:%S %z" => time.strftime("%A, %d de %B de %Y %H:%M:%S %z"),
             "%a, %d %b %Y %H:%M:%S %z" => time.strftime("%a, %d %b %Y %H:%M:%S %z"),
             "%A, %e. %B %Y, %H:%M" => time.strftime("%A, %e. %B %Y, %H:%M"),
             "%a %d %b %Y %H:%M:%S %z" => time.strftime("%a %d %b %Y %H:%M:%S %z"),
             "%a, %d %b %Y %H.%M.%S %z" => time.strftime("%a, %d %b %Y %H.%M.%S %z"),
             "%Y-%m-%d %H:%M" => time.strftime("%Y-%m-%d %H:%M"),
             "%Y年%b%d號 %A %H:%M:%S %Z" => time.strftime("%Y年%b%d號 %A %H:%M:%S %Z"),
             "%a %d %b %Y %H:%M:%S %Z" => time.strftime("%a %d %b %Y %H:%M:%S %Z")}      
     end
=begin
   Contains all the long time formats for a drop down 
=end   
     def long_time_collection time      
       return {"%d. %B, %Y ob %H:%M" => time.strftime("%d. %B, %Y ob %H:%M"),
               "%d %B, %Y %H:%M" => time.strftime("%d %B, %Y %H:%M"),
               "%d %B %Y %H:%M น." => time.strftime("%d %B %Y %H:%M น."),
               "%Y. gada %e. %B, %H:%M:%S" => time.strftime("%Y. gada %e. %B, %H:%M:%S"),
               "%d %B %Y, %H:%M" => time.strftime("%d %B %Y, %H:%M"),
               "%A %d %B %Y %H:%M" => time.strftime("%A %d %B %Y %H:%M"),
               "%e %B %Y %H:%M" => time.strftime("%e %B %Y %H:%M"),
               "%A %d %B %Y %H:%M:%S %Z" => time.strftime("%A %d %B %Y %H:%M:%S %Z"),
               "%Y年%m月%d日(%a) %H時%M分%S秒 %z" => time.strftime("%Y年%m月%d日(%a) %H時%M分%S秒 %z"),
               "%Y年%b%d日 %H:%M" => time.strftime("%Y年%b%d日 %H:%M"),
               "%Y %B %d, %H:%M:%S" => time.strftime("%Y %B %d, %H:%M:%S"),
               "%d de %B de %Y %H:%M" => time.strftime("%d de %B de %Y %H:%M"),
               "%d %B %Y %H:%M" => time.strftime("%d %B %Y %H:%M"),
               "%B %d, %Y %I:%M %p" => time.strftime("%B %d, %Y %I:%M %p"),
               "%d %B %Y %H.%M" => time.strftime("%d %B %Y %H.%M"),
               "%A, %d. %B %Y, %H:%M Uhr" => time.strftime("%A, %d. %B %Y, %H:%M Uhr"),
               "%B %d, %Y %H:%M" => time.strftime("%B %d, %Y %H:%M"),
               "%Y年%b%d號 %H:%M" => time.strftime("%Y年%b%d號 %H:%M"),
               "%Y. %B %e., %A, %H:%M" => time.strftime("%Y. %B %e., %A, %H:%M"),
               "%e. %Bta %Y %H.%M" => time.strftime("%e. %Bta %Y %H.%M"),
               "%a, %d. %b %Y, %H:%M:%S %z" => time.strftime("%a, %d. %b %Y, %H:%M:%S %z"),
               "%Y년 %B월 %d일, %H시 %M분 %S초 %Z" => time.strftime("%Y년 %B월 %d일, %H시 %M분 %S초 %Z"),
               "%A, %d de %B de %Y, %H:%Mh" => time.strftime("%A, %d de %B de %Y, %H:%Mh"),
               "%A, %e. %B %Y, %H:%M" => time.strftime("%A, %e. %B %Y, %H:%M"),
               "%A %d. %B %Y %H:%M" => time.strftime("%A %d. %B %Y %H:%M")}            
     end
=begin     @deprecated
     def array_editor trans
       html = ""
       html = html + form_for(trans, as: :translation, url: translation_path(trans), method: :patch, remote: true,  html: { class: "edit", id: "edit_translation" } )do |f| 
             html = html + f.text_field(:translation, :id => "translation_translation", :style=> "display:none")
             html = html + text_field_tag("editor",  "#{trans.attributes['editor']}", :style=> "display:none")
             html = html + text_field_tag("original_translation",  "#{trans.attributes['translation']}", :style=> "display:none")
             html = html + text_field_tag("dot_key_code",  "#{trans.attributes['dot_key_code']}", :style=> "display:none")
             
             html = html + text_field_tag("english",  "#{trans.attributes['en_translation']}", :style=> "display:none")
             if  trans.attributes["editor"] == 'array_order' then
               html = html + "<ul id= 'sortable' style='list-style: none; margin: 3px; padding: 3px;'></ul>" 
             elsif trans.attributes["editor"] == 'array' || trans.attributes["editor"] == 'array_first_element_null' then
               html = html + "<table id = 'array-special-editor'> </table>" 
             end
             html = html + "<div id ='special-editor-hints' style='display:none;'>" 
             html = html + t($FH + "translation." + special_editor_name(trans.attributes)) + "</div>"
             html = html + "<br>" 
             html = html + f.submit(t($FA + 'save'), :id=>"ok-special-editor", :style=> "display:none")
             html = html + button_tag(t($FA +  "cancel"), :type=>"button", :id=> 'cancel-special-editor', :style=> "display:none")
           end #form
     end
=end
     def tooltip_label code
       return TranslationHint.new(:dot_key_code => code, :heading=> "Label: " + tooltip_general_help , :example=> "'activerecord.attributes.user.actual_name'. Label could be 'Enter real name of user' or simply(and better) 'Real Name'", :description=> "1 or a few words that describe the attribute name or what the user has to to with this field" )
     end
     
     def tooltip_hint code
       return TranslationHint.new(:dot_key_code => code, :heading=> "Hint" + tooltip_general_help , :example=> "'formastic.hints.user.actual_name'. Hint could be 'This is real name of the user in everyday life. For example user 'jsmith34' would be entered hear as 'John Smith'", :description=> "An extended description of the attribute(1 or 2 sentences)" )
     end
     
     def tooltip_action code
       return TranslationHint.new(:dot_key_code => code, :heading=> "Action that can be Taken by User" + tooltip_general_help , :example=> "'formastic.action.publish_translation' could be shown to the user as 'Publish This Translation now'", :description=> "Short few word to indicate what action a user can take if he presses this button" )
     end
     def tooltip_general_help 
       "<span class='tt-general-help'>(General Help)</span>"
     end
=begin     
     def new_translation_hint code
       return TranslationHint.new(:dot_key_code => code)
     end
=end
     def translation_tooltip attrs
       code = attrs["dot_key_code"]
       #tooltip = t($FH + "translation.dot_key_codes." + code.gsub(".", "_"))
       tooltip = TranslationHint.where{dot_key_code == my{code}}.load
       if not tooltip.empty? then
         
         return display_tooltip(tooltip.first)
      
       #if tooltip.include?('translation missing') then
           #return ''     
       #elsif code == "activemodel.errors.format" then
     
         #return t($FH + "translation.dot_key_codes." + code.gsub(".", "_"))
       
       elsif code.start_with? "activerecord.models." then  
         tt = TranslationHint.new(:dot_key_code => code, :heading=> 'Singular or Plural of an Object', :example=> "'activerecord.model.user.one' asks for the singular of User: ie 'User'<br>'activerecord.model.user.other' asks for the plural of User ie 'Users'", :description=> "Singular and Plurals of different sorts are asked for in this code.<br> 'one' always indictes singular<br> 'few' and 'many' are valid plurals in some languages<br>'other' takes care of all the rest (usually none as well) " )
         #return display_tooltip(tt)
       elsif code.start_with? "activerecord.attributes." then
         tt = tooltip_label(code)
         #return display_tooltip(tt)
       elsif code.start_with? "formtastic.labels." then
         tt = tooltip_label(code)
         #return display_tooltip(tt)
       elsif code.start_with? "formtastic.hints." then
         tt = tooltip_hint(code)
         #return display_tooltip(tt)
       elsif code.start_with? "formtastic.actions." then
         tt = tooltip_action(code)  
         #return display_tooltip(tt) 
       elsif code.start_with? "menus."
         tt = TranslationHint.new(:dot_key_code => code, :heading=> "Menu Choice" + tooltip_general_help , :description=> "The user can often go to another page by clicking on a menu item" )
         #return display_tooltip(tt)
       elsif code.start_with? "tabs."
         tt = TranslationHint.new(:dot_key_code => code, :heading=> "Tab Name" + tooltip_general_help ,  :description=> "Sometime data for a user is put in different 'index cards' hidden behind each other. A user clicks on a tab to move from 1 'index card' to another" )
         #return display_tooltip(tt)
       elsif code.start_with? "roles.actions."
         tt = TranslationHint.new(:dot_key_code => code, :heading=> "Role Action" + tooltip_general_help , :example=> "Edit Course, Delete Student",:description=> "A user can be given a role consists of a number of actions." )
         #return display_tooltip(tt)
       elsif code.start_with? "roles."
         tt = TranslationHint.new(:dot_key_code => code, :heading=> "Role" + tooltip_general_help ,:example=> "System Admin, Translator, Scheduler", :description=> "A user role which consists of various actions, must have a name" )
         #return display_tooltip(tt)
       elsif code.start_with? "lookups."
         tt = TranslationHint.new(:dot_key_code => code, :heading=> "Lookup" + tooltip_general_help , :example=> "Course Type has choices like '10 Day Course', '3 Day Course' etc, ", :description=> "A lookup is needed when a certain attribute has a number of fixed choices. The choices need translation. " )
         #return display_tooltip(tt)
       elsif code.start_with? "headings."
         tt = TranslationHint.new(:dot_key_code => code, :heading=> "Page Heading" + tooltip_general_help , :example=> "'List of Courses', Student Form", :description=> "The heading on a page in an application" )
         #return display_tooltip(tt)  
       elsif code.start_with? "commons.search.operator."
         tt = TranslationHint.new(:dot_key_code => code, :heading=> "Search Criterion Operator" + tooltip_general_help , :example=> "'commons.search.operator.starts_with' could be choose to find a name that begins with 'br'. This would find names like 'Bruce', 'Brian'", :description=> "Operators are selected by the user to use in queries for the database. eg 'greater than', 'between', 'equal to' " )
         #return display_tooltip(tt)     
       elsif code.start_with? "commons."
          tt = TranslationHint.new(:dot_key_code => code, :heading=> "Common Words" + tooltip_general_help , :description=> "Frequently used words that need tranlating." )
         return display_tooltip(tt) 
       elsif code.start_with? "simpleform.labels." then
         tt = tooltip_label(code)
         #return display_tooltip(tt)
       elsif code.start_with? "simpleform.hints." then
         tt = tooltip_hint(code)
         #return display_tooltip(tt)
       elsif code.start_with? "simpleform.placeholders." then
         tt = TranslationHint.new(:dot_key_code => code, :heading=> "PlaceHolder" + tooltip_general_help ,  :description=> "Similar to Label: a word to go into the field where the user is to type before they tyype anything e.g. 'password' " )
         #return display_tooltip(tt) 
       elsif code.start_with? "simpleform.prompts." then
         tt = TranslationHint.new(:dot_key_code => code, :heading=> "Prompt" + tooltip_general_help , :description=> "Similar to Label: Short few words to tell the user what to do." )
         #return display_tooltip(tt)
       #elsif code.start_with? "simpleform.include_blanks." then
         #tt = TranslationHint.new(:dot_key_code => code, :heading=> 'Singular or Plural of an Object', :example=> "", :description=> "Singular and Plurals of different sorts are asked for in this code.<br> 'one' always indictes singular<br> 'few' and 'many' are valid plurals in some languages<br>'other' takes care of all the rest (usually none as well) " )
        # return display_tooltip(tt)  
       elsif code.start_with? "helpers.submit." then
         tt = tooltip_action(code)  
         #return display_tooltip(tt)                 
       else
         tt= TranslationHint.new(:dot_key_code => code, :heading=> 'No Tooltip for this code', :description=> "Use the code and English translation to understand what to do")
       end  
       display_tooltip(tt)  
     end
     
     def display_tooltip translation_hint
   
       if not translation_hint.description.blank?
        th_description_html = "<div class= 'tt-description'>" + translation_hint.description + "</div>"
       end
       if not translation_hint.dot_key_code.blank?
        th_dot_key_code_heading_html = "<div class='tt-heading'>" + translation_hint.dot_key_code + "</div>"
       end
       if not translation_hint.example.blank?
        th_example_html  = "<div class= 'tt-example'><p class= 'tt-example-head'>Example</p>" + translation_hint.example + "</div>"
       end
       if not translation_hint.heading.blank?
        th_heading_html = "<div class='tt-heading'>" + translation_hint.heading + "</div>"
       end
       th_div_open_html = "<div class = 'translation_hint'>" 
       if translation_hint.description.blank? && translation_hint.example.blank? && translation_hint.heading.blank?
         ret_val = th_div_open_html + translation_hint.dot_key_code + "</div>"
       elsif translation_hint.description.blank?  && translation_hint.example.blank?
         ret_val = th_div_open_html + th_heading_html  + "</div>"
       elsif translation_hint.description.blank?  && translation_hint.heading.example?
          ret_val = th_div_open_html + th_example_html + "</div>"
       elsif translation_hint.example.blank? && translation_hint.heading.blank?
         #"<div class = 'translation_hint'>" +  th_description_html  + "</div>"
         ret_val = th_div_open_html +  th_description_html  + "</div>"
       elsif translation_hint.heading.blank? #&& translation_hint.description.blank?
         ret_val = th_div_open_html + th_dot_key_code_heading_html + th_example_html  + th_description_html + "</div>"  
       elsif translation_hint.example.blank? #&& translation_hint.description.blank?
         ret_val = th_div_open_html + th_heading_html + th_description_html + "</div>"
       elsif translation_hint.description.blank? #&& translation_hint.description.blank?
         ret_val = th_div_open_html + th_heading_html + th_example_html  + "</div>"
       else # all fields filled in  
        ret_val = th_div_open_html + th_heading_html + th_example_html  + th_description_html + "</div>"  
       end
       return ret_val.html_safe
     end
     
    def permitted_to_destroy?( translation, attrs) 
      return permitted_to?(:delete,  translation) && attrs["language"] == 'en'
    end  
     
    def width_style(iso_code = nil)
      if iso_code.blank?
         return {:dot_key_code => "", :translation=> "", :en_translation=> "", :special_structure=>"", :delete => "" }
      elsif iso_code == 'en'
        return {:dot_key_code => "width:40%;", :translation=> "width:40%;", :special_structure=>"width:5%;", :incomplete => "width:5%;", :delete => "width:10%;" }
      else  
        return {:dot_key_code => "width:20%;", :translation=> "width:40%;", :en_translation=> "width:30%;", :special_structure=>"width:5%;", :incomplete => "width:5%;" }
      end
    end
end #module