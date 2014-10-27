module TranslationHelper
#binding.pry
=begin
 #return true Use best_in_place as editor
 @return false Display as plain text  
=end
  def best_in_place?(attrs)
    #binding.pry
    #return true if (attrs['cldr'].nil? and  attrs["editor"].nil?) or 
    #                editor_date_time_select?(attrs)
    
    return true if ( attrs["editor"].nil?) or 
                editor_date_time_select?(attrs) or editor_number_select?(attrs)
    
    return false  
  end
=begin
 Sets html attributes for the editor control in best in place 
=end  
  def input_text? attrs
    return (:input  ==  input_control(attrs))
  end
  def html_attrs(object_attrs)
     #binding.pry
     if input_control(object_attrs) == :select then
       size = '8'
     else
       size = '40'
     end
     retVal =  { :placeHolder => "Click to translate", :size=> size} 
     # could not integrate Autosize.Input
     #extra = {"data-autosize-input" => '{ "space": 40 }'} 
     #extra_css_auto = 'width: 250px; min-width: 250px; max-width: 300px; transition: 0.25s;'
     #extra_css = 'width: 250px;'
     #retVal.merge!(extra) if input_text?(object_attrs)
     #retVal[:style] << extra_css if input_text?(object_attrs)
     return retVal
   end 
   #placeholder="Autosize" data-autosize-input='{ "space": 40 }' 
=begin
 @return the correct input control for best in place editing 
=end   
   def input_control(attrs)
      #if attrs["en_translation"].length >35
      #binding.pry
      #end
       if (not attrs["en_translation"].nil?) && attrs["en_translation"].length  > 40 && attrs["editor"].nil? then
         return :textarea
       elsif attrs["editor"] == "date_format" then
         return :select
       elsif attrs["editor"] == "time_format" then  
         return :select
       elsif attrs["editor"] == "datetime_format" then  
         return :select
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
   def format_translation translation
     return translation
     
   end
=end

=begin
  Formats the english transation on the index
=end   
   def format_english attributes
     
     return english_date_format_example(attributes) if editor_date_time_select?(attributes)  
     return "<i>[This plural not used in English]</i>".html_safe if attributes["en_translation"].nil?
     return "<i>[Not used in English, so left blank. It may be left blank in your language too.] </i>".html_safe if attributes["en_translation"].blank?
     return attributes["en_translation"]
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
   def english_date_format_example attrs
     return example_date.strftime(attrs['en_translation']) 
   end
=begin
  
=end   
   def translated_full_abbrev_day_month(date, iso_code, version_id)
     dow = date.wday
     month = date.month  
     #binding.pry
     day_abbrev = JSON.parse(Translation.single_lang_translations_arr(iso_code,version_id).where{dot_key_code ==  "date.abbr_day_names"}.first.translation)[dow]
     day_full = JSON.parse(Translation.single_lang_translations_arr(iso_code,version_id).where{dot_key_code ==  "date.day_names"}.first.translation)[dow]
     month_abbrev = JSON.parse(Translation.single_lang_translations_arr(iso_code,version_id).where{dot_key_code ==  "date.abbr_month_names"}.first.translation)[month]
     month_full = JSON.parse(Translation.single_lang_translations_arr(iso_code,version_id).where{dot_key_code ==  "date.month_names"}.first.translation)[month]
     result = {month_full: month_full, month_abbrev: month_abbrev, day_full: day_full, day_abbrev: day_abbrev}.with_indifferent_access  
   end

=begin
 @return the correct collection of formats for date, datetime and time select controls
=end   
   def collection? attrs 
     # Arrays generated with sql : "select '["' || translation || '", time.strftime("' || translation || '")],' from  translations where dot_key_code ilike 'time.formats.short';"
     if input_control(attrs) == :select then
       #binding.pry
       if attrs["editor"] == "date_format" then
         date = example_date
         iso_code = attrs["iso_code"]
         return short_date_collection(date, iso_code, attrs["version_id"]) if attrs["dot_key_code"] == 'date.formats.short'
         return default_date_collection(date, iso_code, attrs["version_id"]) if attrs["dot_key_code"] == 'date.formats.default'
         return long_date_collection(date, iso_code, attrs["version_id"]) if attrs["dot_key_code"] == 'date.formats.long'
       elsif  attrs["editor"] == "datetime_format" then  
         datetime =  example_date                     
         return datetime_collection(datetime, iso_code, attrs["version_id"])  if attrs["dot_key_code"] == 'datetime.formats.course_form'
       elsif attrs["editor"] == "time_format" then
         time = example_time
         return short_time_collection(time) if attrs["dot_key_code"] == 'time.formats.short'
         return default_time_collection(time) if attrs["dot_key_code"] == 'time.formats.default'
         return long_time_collection(time) if attrs["dot_key_code"] == 'time.formats.long'  
       end    
     end  
   end #def     

=begin
 @return the name of the special editor (outside best in place) 
=end     
   def special_editor_name(attrs)
     return attrs["editor"]
   end 
=begin @deprecated   
   def special_editor_div2(attrs, trans)
     html = "<div id = '#{attrs['dot_key_code']}' class = 'special_editor #{special_editor_name(attrs)}' style = 'display:none;'>"
     #binding.pry
     html.concat(form_for(translation_path(364), :remote => true, :html=>{:method=>'get'})  do |f|
       f.text_field(:id, :style => "display:inline")
       f.text_field(:translation) 
     end)
     html.concat("<input id = 'dot_key_code' type= 'text' value ='" + attrs["dot_key_code"] + "' style='display:inline;' readonly='readonly'>")
     html.concat("<input id = 'original_translation' type= 'text' value ='" + attrs["translation"] + "' style='display:inline;' readonly='readonly'>")
     hint = ''
     if special_editor_name(attrs) == "array_order" then
       #binding.pry
       html.concat("<ul id= 'sortable'>")
       html.concat("</ul>")
       hint  = "Drag the elements into the correct order and then Save."
     end
     html.concat("<p class='inline-hints'>" + hint + "</p>")
     #html.concat("<button id= 'ok-special-editor'>Save</button>")
     html.concat(button_to("Save", trans) )
     html.concat("<button id= 'cancel-special-editor'>Cancel</button>")
     html.concat("</div>")
     return html.html_safe
   end
   @deprecated
   def special_editor_div(attrs, trans)
     html = "<div id = '#{attrs['dot_key_code']}' class = 'special_editor #{special_editor_name(attrs)}' style = 'display:none;'>"
     html.concat("<input id = 'id' type= 'text' value ='" + attrs["id"].to_s + "' style='display:inline;'  readonly='readonly'>")
     html.concat("<input id = 'dot_key_code' type= 'text' value ='" + attrs["dot_key_code"] + "' style='display:inline;' readonly='readonly'>")
     html.concat("<input id = 'original_translation' type= 'text' value ='" + attrs["translation"] + "' style='display:inline;' readonly='readonly'>")
     hint = ''
     if special_editor_name(attrs) == "array_order" then
       #binding.pry
       html.concat("<ul id= 'sortable'>")
       html.concat("</ul>")
       hint  = "Drag the elements into the correct order and then Save."
     end
     html.concat("<p class='inline-hints'>" + hint + "</p>")
     html.concat("<button id= 'ok-special-editor'>Save</button>")
     #html.concat(button_to("Save", trans) )
     html.concat("<button id= 'cancel-special-editor'>Cancel</button>")
     html.concat("</div>")
     #binding.pry
     return html.html_safe
   end
=end 

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
     #binding.pry
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
     #binding.pry
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
   private
=begin
 Contains all the short date formats for a drop down 
=end
     def short_date_collection date, iso_code, version_id
       language_hash = translated_full_abbrev_day_month(date, iso_code, version_id)
       en_hash =  translated_full_abbrev_day_month(date, 'en', version_id) 
       #binding.pry
=begin
       return [["%-d %b", localised_date("%-d %b", date, language_hash, en_hash)],
               ["%m/%d", localised_date("%m/%d", date, language_hash, en_hash)],
               ["%d.%m.%Y", localised_date("%d.%m.%Y", date, language_hash, en_hash)],
               ["%b%d日", localised_date("%b%d日", date, language_hash, en_hash)],
               ["%e %b", localised_date("%e %b", date, language_hash, en_hash)],
               ["%b %e.", localised_date("%b %e.", date, language_hash, en_hash)],
               ["%e.%m.%Y", localised_date("%e.%m.%Y", date, language_hash, en_hash)],
               ["%d de %b", localised_date("%d de %b", date, language_hash, en_hash)],
               ["%e. %b", localised_date("%e. %b", date, language_hash, en_hash)],
               ["%e. %B", localised_date("%e. %B", date, language_hash, en_hash)],
               ["%b %d", localised_date("%b %d", date, language_hash, en_hash)],
               ["%d %b", localised_date("%d %b", date, language_hash, en_hash)],
               ["%d de %B", localised_date("%d de %B", date, language_hash, en_hash)],
               ["%d.%m.%y", localised_date("%d.%m.%y", date, language_hash, en_hash)],
               ["%y-%m-%d", localised_date("%y-%m-%d", date, language_hash, en_hash)],
               ["%m-%d-%Y", localised_date("%m-%d-%Y", date, language_hash, en_hash)],
               ["%m/%d/%Y", localised_date("%m/%d/%Y", date, language_hash, en_hash)],
               ["%d. %b", localised_date("%d. %b", date, language_hash, en_hash)]]
=end               
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
=begin
       return [["%d %B %Y", localised_date("%d %B %Y", date, language_hash, en_hash)],
               ["%d. %m. %Y", localised_date("%d. %m. %Y", date, language_hash, en_hash)],
               ["%e. %Bta %Y", localised_date("%e. %Bta %Y", date, language_hash, en_hash)],
               ["%d.%m.%Y", localised_date("%d.%m.%Y", date, language_hash, en_hash)],
               ["%d/%m/%Y", localised_date("%d/%m/%Y", date, language_hash, en_hash)],
               ["%d.%m.%Y.", localised_date("%d.%m.%Y.", date, language_hash, en_hash)],
               ["%Y.%m.%d.", localised_date("%Y.%m.%d.", date, language_hash, en_hash)],
               
               ["%Y-%m-%d", localised_date("%Y-%m-%d", date, language_hash, en_hash)],
               ["%d-%m-%Y", localised_date("%d-%m-%Y", date, language_hash, en_hash)],
               ["%Y/%m/%d", localised_date("%Y/%m/%d", date, language_hash, en_hash)]] 
=end
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
=begin       
       return [["%Y年%b%d日", localised_date("%Y年%b%d日", date, language_hash, en_hash)],
               ["%Y년 %m월 %d일 (%a)", localised_date("%Y년 %m월 %d일 (%a)", date, language_hash, en_hash)],
               ["%Y. %B %e.", localised_date("%Y. %B %e.", date, language_hash, en_hash)],
               ["%Y %B %d", localised_date("%Y %B %d", date, language_hash, en_hash)],
               ["%B %e, %Y", localised_date("%B %e, %Y", date, language_hash, en_hash)],
               ["%e %B %Y", localised_date("%e %B %Y", date, language_hash, en_hash)],
               ["%A %e. %Bta %Y", localised_date("%A %e. %Bta %Y", date, language_hash, en_hash)],
               ["%Y. gada %e. %B", localised_date("%Y. gada %e. %B", date, language_hash, en_hash)],
               ["%e. %B %Y", localised_date("%e. %B %Y", date, language_hash, en_hash)],
               ["%d %B, %Y", localised_date("%d %B, %Y", date, language_hash, en_hash)],
               ["%A, %d %B %Y", localised_date("%A, %d %B %Y", date, language_hash, en_hash)],
               ["%Y年%m月%d日(%a)", localised_date("%Y年%m月%d日(%a)", date, language_hash, en_hash)],
               ["%d. %B %Y", localised_date("%d. %B %Y", date, language_hash, en_hash)],
               ["%d de %B de %Y", localised_date("%d de %B de %Y", date, language_hash, en_hash)],
               ["%-d %B %Y", localised_date("%-d %B %Y", date, language_hash, en_hash)],
               ["%d. %b %Y", localised_date("%d. %b %Y", date, language_hash, en_hash)],
               ["%B %d, %Y", localised_date("%B %d, %Y", date, language_hash, en_hash)],
               ["%a %e/%b/%Y", localised_date("%a %e/%b/%Y", date, language_hash, en_hash)],
               ["%a %b-%e-%Y", localised_date("%a %b-%e-%Y", date, language_hash, en_hash)],
               ["%a %b/%e/%Y", localised_date("%a %b/%e/%Y", date, language_hash, en_hash)],
               ["%a %e-%b-%Y", localised_date("%a %e-%b-%Y", date, language_hash, en_hash)],
               ["%d %B %Y", localised_date("%d %B %Y", date, language_hash, en_hash)]]
=end               
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
     def datetime_collection date, datetime, version_id
       language_hash = translated_full_abbrev_day_month(date, iso_code, version_id)
       en_hash =  translated_full_abbrev_day_month(date, 'en', version_id)
=begin
       return [["%a %b-%e-%Y", datetime.strftime("%a %b-%e-%Y", date, language_hash, en_hash)],
               ["%a %b/%e/%Y", datetime.strftime("%a %b/%e/%Y", date, language_hash, en_hash)],
               ["%a %e-%b-%Y", datetime.strftime("%a %e-%b-%Y", date, language_hash, en_hash)]] 
=end               
       return {"%a %b-%e-%Y" => datetime.strftime("%a %b-%e-%Y", date, language_hash, en_hash),
               "%a %b/%e/%Y" => datetime.strftime("%a %b/%e/%Y", date, language_hash, en_hash),
               "%a %e-%b-%Y" => datetime.strftime("%a %e-%b-%Y", date, language_hash, en_hash)}        
     end 
=begin
   Contains all the short datetime formats for a drop down 
=end   
     def short_time_collection time
=begin
         return [["%d. %m. %H:%M", time.strftime("%d. %m. %H:%M")],
             ["%e %b %H:%M", time.strftime("%e %b %H:%M")],
             ["%b %e., %H:%M", time.strftime("%b %e., %H:%M")],
             ["%d/%m, %H:%M hs", time.strftime("%d/%m, %H:%M hs")],
             ["%d.%m.%Y., %H:%M", time.strftime("%d.%m.%Y., %H:%M")],
             ["%b%d日 %H:%M", time.strftime("%b%d日 %H:%M")],
             ["%d. %b ob %H:%M", time.strftime("%d. %b ob %H:%M")],
             ["%d %b %I:%M %p", time.strftime("%d %b %I:%M %p")],
             ["%e.%m. %H.%M", time.strftime("%e.%m. %H.%M")],
             ["%d %b, %H:%M", time.strftime("%d %b, %H:%M")],
             ["%d %b %H.%M", time.strftime("%d %b %H.%M")],
             ["%y/%m/%d %H:%M", time.strftime("%y/%m/%d %H:%M")],
             ["%d.%m. %H:%M", time.strftime("%d.%m. %H:%M")],
             ["%d de %b %H:%M", time.strftime("%d de %b %H:%M")],
             ["%b%d號 %H:%M", time.strftime("%b%d號 %H:%M")],
             ["%d %b %H:%M", time.strftime("%d %b %H:%M")],
             ["%d.%m.%y, %H:%M", time.strftime("%d.%m.%y, %H:%M")],
             ["%d. %B, %H:%M Uhr", time.strftime("%d. %B, %H:%M Uhr")],
             ["%y-%m-%d", time.strftime("%y-%m-%d")],
             ["%d %b %H:%M น.", time.strftime("%d %b %H:%M น.")],
             ["%e. %B, %H:%M", time.strftime("%e. %B, %H:%M")] ].to_json
=end             
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
=begin
       return [["%A, %d %b %Y ob %H:%M:%S", time.strftime("%A, %d %b %Y ob %H:%M:%S")],
             ["%A %e. %Bta %Y %H:%M:%S %z", time.strftime("%A %e. %Bta %Y %H:%M:%S %z")],
             ["%Y. gada %e. %B, %H:%M", time.strftime("%Y. gada %e. %B, %H:%M")],
             ["%Y年%b%d日 %A %H:%M:%S %Z", time.strftime("%Y年%b%d日 %A %H:%M:%S %Z")],
             ["%d %B %Y %H:%M:%S", time.strftime("%d %B %Y %H:%M:%S")],
             ["%a, %e %b %Y %H:%M:%S %z", time.strftime("%a, %e %b %Y %H:%M:%S %z")],
             ["%a, %d %b %Y %I:%M:%S %p %Z", time.strftime("%a, %d %b %Y %I:%M:%S %p %Z")],
             ["%d %B %Y %H:%M", time.strftime("%d %B %Y %H:%M")],
             ["%a %b %d %H:%M:%S %Z %Y", time.strftime("%a %b %d %H:%M:%S %Z %Y")],
             ["%A, %d. %B %Y, %H:%M Uhr", time.strftime("%A, %d. %B %Y, %H:%M Uhr")],
             ["%Y. %b %e., %H:%M", time.strftime("%Y. %b %e., %H:%M")],
             ["%a, %d %b %Y, %H:%M:%S %z", time.strftime("%a, %d %b %Y, %H:%M:%S %z")],
             ["%d. %B %Y, %H:%M", time.strftime("%d. %B %Y, %H:%M")],
             ["%Y/%m/%d %H:%M:%S", time.strftime("%Y/%m/%d %H:%M:%S")],
             ["%a %d. %B %Y %H:%M %z", time.strftime("%a %d. %B %Y %H:%M %z")],
             ["%A, %d de %B de %Y, %H:%Mh", time.strftime("%A, %d de %B de %Y, %H:%Mh")],
             ["%a %d %b %Y, %H:%M:%S %z", time.strftime("%a %d %b %Y, %H:%M:%S %z")],
             ["%A, %d de %B de %Y %H:%M:%S %z", time.strftime("%A, %d de %B de %Y %H:%M:%S %z")],
             ["%a, %d %b %Y %H:%M:%S %z", time.strftime("%a, %d %b %Y %H:%M:%S %z")],
             ["%A, %e. %B %Y, %H:%M", time.strftime("%A, %e. %B %Y, %H:%M")],
             ["%a %d %b %Y %H:%M:%S %z", time.strftime("%a %d %b %Y %H:%M:%S %z")],
             ["%a, %d %b %Y %H.%M.%S %z", time.strftime("%a, %d %b %Y %H.%M.%S %z")],
             ["%Y-%m-%d %H:%M", time.strftime("%Y-%m-%d %H:%M")],
             ["%Y年%b%d號 %A %H:%M:%S %Z", time.strftime("%Y年%b%d號 %A %H:%M:%S %Z")],
             ["%a %d %b %Y %H:%M:%S %Z", time.strftime("%a %d %b %Y %H:%M:%S %Z")]]
=end             
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
=begin       
       return [["%d. %B, %Y ob %H:%M", time.strftime("%d. %B, %Y ob %H:%M")],
               ["%d %B, %Y %H:%M", time.strftime("%d %B, %Y %H:%M")],
               ["%d %B %Y %H:%M น.", time.strftime("%d %B %Y %H:%M น.")],
               ["%Y. gada %e. %B, %H:%M:%S", time.strftime("%Y. gada %e. %B, %H:%M:%S")],
               ["%d %B %Y, %H:%M", time.strftime("%d %B %Y, %H:%M")],
               ["%A %d %B %Y %H:%M", time.strftime("%A %d %B %Y %H:%M")],
               ["%e %B %Y %H:%M", time.strftime("%e %B %Y %H:%M")],
               ["%A %d %B %Y %H:%M:%S %Z", time.strftime("%A %d %B %Y %H:%M:%S %Z")],
               ["%Y年%m月%d日(%a) %H時%M分%S秒 %z", time.strftime("%Y年%m月%d日(%a) %H時%M分%S秒 %z")],
               ["%Y年%b%d日 %H:%M", time.strftime("%Y年%b%d日 %H:%M")],
               ["%Y %B %d, %H:%M:%S", time.strftime("%Y %B %d, %H:%M:%S")],
               ["%d de %B de %Y %H:%M", time.strftime("%d de %B de %Y %H:%M")],
               ["%d %B %Y %H:%M", time.strftime("%d %B %Y %H:%M")],
               ["%B %d, %Y %I:%M %p", time.strftime("%B %d, %Y %I:%M %p")],
               ["%d %B %Y %H.%M", time.strftime("%d %B %Y %H.%M")],
               ["%A, %d. %B %Y, %H:%M Uhr", time.strftime("%A, %d. %B %Y, %H:%M Uhr")],
               ["%B %d, %Y %H:%M", time.strftime("%B %d, %Y %H:%M")],
               ["%Y年%b%d號 %H:%M", time.strftime("%Y年%b%d號 %H:%M")],
               ["%Y. %B %e., %A, %H:%M", time.strftime("%Y. %B %e., %A, %H:%M")],
               ["%e. %Bta %Y %H.%M", time.strftime("%e. %Bta %Y %H.%M")],
               ["%a, %d. %b %Y, %H:%M:%S %z", time.strftime("%a, %d. %b %Y, %H:%M:%S %z")],
               ["%Y년 %B월 %d일, %H시 %M분 %S초 %Z", time.strftime("%Y년 %B월 %d일, %H시 %M분 %S초 %Z")],
               ["%A, %d de %B de %Y, %H:%Mh", time.strftime("%A, %d de %B de %Y, %H:%Mh")],
               ["%A, %e. %B %Y, %H:%M", time.strftime("%A, %e. %B %Y, %H:%M")],
               ["%A %d. %B %Y %H:%M", time.strftime("%A %d. %B %Y %H:%M")]]
=end               
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
end #module