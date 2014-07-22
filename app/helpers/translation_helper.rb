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
                editor_date_time_select?(attrs)
    
    return false  
  end
=begin
 Sets html attributes for the editor control in best in place 
=end  
  def input_text? attrs
    return (:input  ==  input_control(attrs))
  end
  def html_attrs(object_attrs)
    
     retVal =  {:style=>'background-color: yellow;', :placeHolder => "Click to translate", :size=> '40'} 
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
     return %w(date_format time_format datetime_format).include? attrs['editor']
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
     return "<i>[Not used in English, so left blank]</i>".html_safe if attributes["en_translation"].blank?
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
 Contains all the short date formats for a drop down 
=end
   def short_date_collection date
     return [["%-d %b", date.strftime("%-d %b")],
             ["%m/%d", date.strftime("%m/%d")],
             ["%d.%m.%Y", date.strftime("%d.%m.%Y")],
             ["%b%d日", date.strftime("%b%d日")],
             ["%e %b", date.strftime("%e %b")],
             ["%b %e.", date.strftime("%b %e.")],
             ["%e.%m.%Y", date.strftime("%e.%m.%Y")],
             ["%d de %b", date.strftime("%d de %b")],
             ["%e. %b", date.strftime("%e. %b")],
             ["%e. %B", date.strftime("%e. %B")],
             ["%b %d", date.strftime("%b %d")],
             ["%d %b", date.strftime("%d %b")],
             ["%d de %B", date.strftime("%d de %B")],
             ["%d.%m.%y", date.strftime("%d.%m.%y")],
             ["%y-%m-%d", date.strftime("%y-%m-%d")],
             ["%m-%d-%Y", date.strftime("%m-%d-%Y")],
             ["%m/%d/%Y", date.strftime("%m/%d/%Y")],
             ["%d. %b", date.strftime("%d. %b")]]
   end
=begin
  Contains all the default data formats suitable for listing in a drop down
=end   
   def default_date_collection date
     return [["%d %B %Y", date.strftime("%d %B %Y")],
             ["%d. %m. %Y", date.strftime("%d. %m. %Y")],
             ["%e. %Bta %Y", date.strftime("%e. %Bta %Y")],
             ["%d.%m.%Y", date.strftime("%d.%m.%Y")],
             ["%d/%m/%Y", date.strftime("%d/%m/%Y")],
             ["%d.%m.%Y.", date.strftime("%d.%m.%Y.")],
             ["%Y.%m.%d.", date.strftime("%Y.%m.%d.")],
             
             ["%Y-%m-%d", date.strftime("%Y-%m-%d")],
             ["%d-%m-%Y", date.strftime("%d-%m-%Y")],
             ["%Y/%m/%d", date.strftime("%Y/%m/%d")]] 
   end
=begin
 Contains all the long date formats for a drop down 
=end   
   def long_date_collection date
     return [["%Y年%b%d日", date.strftime("%Y年%b%d日")],
             ["%Y년 %m월 %d일 (%a)", date.strftime("%Y년 %m월 %d일 (%a)")],
             ["%Y. %B %e.", date.strftime("%Y. %B %e.")],
             ["%Y %B %d", date.strftime("%Y %B %d")],
             ["%B %e, %Y", date.strftime("%B %e, %Y")],
             ["%e %B %Y", date.strftime("%e %B %Y")],
             ["%A %e. %Bta %Y", date.strftime("%A %e. %Bta %Y")],
             ["%Y. gada %e. %B", date.strftime("%Y. gada %e. %B")],
             ["%e. %B %Y", date.strftime("%e. %B %Y")],
             ["%d %B, %Y", date.strftime("%d %B, %Y")],
             ["%A, %d %B %Y", date.strftime("%A, %d %B %Y")],
             ["%Y年%m月%d日(%a)", date.strftime("%Y年%m月%d日(%a)")],
             ["%d. %B %Y", date.strftime("%d. %B %Y")],
             ["%d de %B de %Y", date.strftime("%d de %B de %Y")],
             ["%-d %B %Y", date.strftime("%-d %B %Y")],
             ["%d. %b %Y", date.strftime("%d. %b %Y")],
             ["%B %d, %Y", date.strftime("%B %d, %Y")],
             ["%a %e/%b/%Y"], [date.strftime("%a %e/%b/%Y")],
             ["%a %b-%e-%Y"], [date.strftime("%a %b-%e-%Y")],
             ["%a %b/%e/%Y"], [date.strftime("%a %b/%e/%Y")],
             ["%a %e-%b-%Y"], [date.strftime("%a %e-%b-%Y")],
             ["%d %B %Y", date.strftime("%d %B %Y")]]
   end 
=begin
 Contains all the default datetime formats for a drop down 
=end   
   def datetime_collection datetime
     return [["%a %b-%e-%Y"], [datetime.strftime("%a %b-%e-%Y")],
             ["%a %b/%e/%Y"], [datetime.strftime("%a %b/%e/%Y")],
             ["%a %e-%b-%Y"], [datetime.strftime("%a %e-%b-%Y")]] 
   end 
=begin
 Contains all the short datetime formats for a drop down 
=end   
   def short_time_collection time
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
           ["%e. %B, %H:%M", time.strftime("%e. %B, %H:%M")] ]
   end
=begin
 Contains all the default time formats for a drop down 
=end   
   def default_time_collection time
     [ ["%A, %d %b %Y ob %H:%M:%S", time.strftime("%A, %d %b %Y ob %H:%M:%S")],
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
   end
=begin
 Contains all the long time formats for a drop down 
=end   
   def long_time_collection time
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
             ["%A %d. %B %Y %H:%M", time.strftime("%A %d. %B %Y %H:%M")] ]
   end
=begin
 @return the correct collection of formats for date, datetime and time select controls
=end   
   def collection? attrs 
     # Arrays generated with sql : "select '["' || translation || '", time.strftime("' || translation || '")],' from  translations where dot_key_code ilike 'time.formats.short';"
     if input_control(attrs) == :select then
       if attrs["editor"] == "date_format" then
         date = example_date
         return short_date_collection(date) if attrs["dot_key_code"] == 'date.formats.short'
         return default_date_collection(date) if attrs["dot_key_code"] == 'date.formats.default'
         return long_date_collection(date) if attrs["dot_key_code"] == 'date.formats.long'
       elsif  attrs["editor"] == "datetime_format" then  
         datetime =  example_date                     
         return datetime_collection(datetime)  if attrs["dot_key_code"] == 'datetime.formats.course_form'
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
end #module