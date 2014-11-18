module TranslationsHelper
  include WillPaginate::ViewHelpers
  include I18n
  
=begin
  These global constants are used as partial keys in yaml translation files
=end
  $A="actions."
  $AM ="activemodel."
  $AR="activerecord."
  $ARA=$AR + "attributes."
  $ARM= $AR + "models."
  $C ="commons."
  $F="formtastic."
  $FL= $F+"labels."
  $FH = $F+"hints."
  $FA = $F + "actions."
  #$L="links."
  $LU="lookups."
  $M="menus."
  $MS="messages." #Used in the context of messages.<situation>[<.situation>].<$E | $W | $N | $S>
    $W ="warning"
    $N = 'notice'
    $S = 'success'
    $E = 'error'
  $MSDS = $MS + 'delete.are_you_sure.' +$W
  $EM = "errors.messages."  #Used for model specific errors errors.messages.<model><.attribute>.error_name  
  #$MSE=$MS+"error."
  #$MSN=$MS+"notice."
  #$MSW=$MS+"warning."
  #$MSS = $MS+ 'success.'
  $S="commons.search."
  $SC=$S + "criteria"
  $SO=$S + "operators."
  
  $D="date."
  $DF=$D + "formats."
  
  $DT ="datetime."
  $DTP= $DT +"prompts."
  $T='time.'
  #$TP="commons.timepicker."
  $TF = "time.formats."
  $DTF= $DT + "formats."
  $TB="tabs."
  $P="placeholders."
  #This is not a language translation but rather to put a date into a format acceptable for use in a db query
  $DB_DF = "%Y-%b-%d" #I18n.t("date.formats.db")

  #$REDIS_PW='123456'
  $TM="translation missing:"
  
  
  #def tmodel model_name, count = 1
    #I18n.t($ARM + model_name, :count=>count )
  #end
=begin
    Reference: http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to
    link_to(*args, &block)
    --------------------
    here I do it not so generally but only for signature:
    link_to(translation_code, url, html_options = {})
    tlink_to translation_code, url
    tlink_to 'destroy', course_type, :confirm => 'delete.are_you_sure', :model => 'course_type', :value => course_type.translation_code  :count => 1, :method => :delete
=end

   def tlink_to(translation_code, url, options = {})
     #if translation_code =='new'
      #binding.pry
     #end
     options[:count] = 1 if options[:model] && options[:count].nil?
     model = options[:model]
     if !model.nil?
       # kludge for backward compatibility: won't work all the time
       if ! model.index(' ') then
         tr_model = I18n.t($ARM + model, options)
       end
       if !(tr_model) || tr_model.index("translation missing") then
         tr_model = model 
       end
       options[:model]= tr_model
     end
     if options[:category].nil? or options[:category]== :action then
       #if options[:method]=="delete" then
         #link_destroy()
      # end
       tlabel = I18n.t($FA + translation_code, options )
     elsif options[:category]== :menu then
       tlabel = tmenu( translation_code)
     else
       tlabel = t(translation_code)
     end
       #if options[:title] then
         #options[:title] = t(options[:title])
       #end
       
     navigate  = options.delete(:navigate)
     #options[:navigate].delete unless options[:navigate].nil?  
     if navigate.nil? or navigate  then   
       #if navigation is involved then we make a link
       link_to tlabel, url, options
     else #navigate == false
       #if it is an action which refreshes or ajaxes on the same page (eg Delete) then we use a button
       button_to tlabel, url, options
     end  
   end

   def tconfirm_option options
     #binding.pry
     if options[:data].nil? then
         options[:data] = {}
       end
       #binding.pry
       if options[:data][:confirm] then
         count = options.delete(:count)
         options[:data][:confirm] = tmessage( options[:data][:confirm], $W, options)
       end
       if options[:confirm] then
         # can't use :count for a translation of a message unless it is expected.
         count = options.delete(:count)
         #binding.pry
         
         options[:data][:confirm] =  tmessage( options[:confirm], $W, options)
       end
       options.delete(:confirm)
       options[:count] = count  
       return options
   end
  # e.g. <%=theading("listing", :model=> "course_type",:count => 2) %>
  # translation_code can be "new, "edit" or "listing" or "home"  according to yaml paths
  def theading(translation_code, options = {})
    if options[:class] then
      klass = options[:class]
    else
      klass= "pageheading"
    end
    #debugger
    count = options[:count]
    options[:count] = 1 if count.nil?
    model = options[:model]

    if !model.nil?
      tr_model = tmodel(model, options) 

      ret_val = I18n.t("headings.#{translation_code}.heading", :model => tr_model)
    else
      #ret_val = "translation missing:" + translation_code + options.to_s
      
    end
    ret_val = "<p class='"+ klass + "'>"+ret_val + "</p>"
    return ret_val.html_safe
  end

=begin
This function will return the translation of objects in lookup tables. The translations come in the form of
<lang>.lookups.<model>.<attribute>
and
<lang>.lookups.<model>.<attribute>.description
lookup_object is the model object e.g. course_type
model_name is the name of the model e.g. "course_type"
translation_type are either "name" or "description". Defaults to name
=end
  def tlookup_value lookup_object =nil, translation_type = nil, model_name=nil
    #debugger
    return "" if lookup_object.nil?
    return "" if lookup_object.id.nil?
    model_name = lookup_object.class.table_name.singularize if model_name.nil?
    model_name = model_name.downcase

    if translation_type.nil? || translation_type["name"] then
      return I18n.t($LU + model_name + "." + lookup_object.translation_code)
    elsif translation_type["description"] then
      return I18n.t($LU +model_name + '.description.'+lookup_object.translation_code)
    else
      #binding.pry
      return $TM + " for " + lookup_object.to_s + " " + (translation_type.nil? ? "" : translation_type)
    end
  end
=begin
This code will facilitate i18n in will_paginate
just substitute twill_paginate for will_paginate
=end
  def twill_paginate(collection = nil, options = {})
      will_paginate collection, {:previous_label => I18n.t('commons.previous'), :next_label => I18n.t('commons.next')}.merge(options)
  end
  # Translates the text of labels for attributes
  def tlabel attribute_name, model_name=nil
    
    if model_name.nil? then
      index=attribute_name.index('.')
      if !index.nil? && attribute_name.count('.') == 1 then
        names=attribute_name.split('.')
        model_name=names[0]
        attribute_name = names[1]
      end
    end
    if model_name.nil? then
      ret_val = I18n.t($FL+attribute_name)
    else
      ret_val = I18n.t($ARA + model_name +"." + attribute_name)
    end
      tm= $TM
      if ret_val.index(tm) then
        if attribute_name.end_with? "_id" then
          ret_val2 = tlabel(attribute_name[0..(attribute_name.length-4)], model_name)
          if ! ret_val2.index(tm) then
            ret_val= ret_val2
          end
        end
      end
      return ret_val
  end
  def tflash message_code,  category=:error, options ={}, now=false
    if ! category.is_a? Symbol then
      category = category.to_s.to_sym
    end
    if options[:model] then
      options[:model] = tmodel(options[:model], options)
    end
    msg = tmessage( message_code, category.to_s, options)
    if now then
      flash.now[category] = msg
    else
      flash[category] =  msg
    end
  end
  def taccordion_header accordian
    return ("<h3><a class ='accordionHeader' href='#'>" + tmenu(accordian) + "</a></h3>").html_safe
  end

  def tmodel model_name, options ={}
    if ! options[:count] then
      options[:count]=1
    end
    I18n.t($ARM + model_name, options )
  end

  def tmessage(subkey, category, interpolations={})
    #binding.pry
    I18n.t($MS + subkey + "." + category,  interpolations)
  end
  

  def tmenu( menu)
     I18n.t($M + menu)
  end

  def tinterpolation_pform translation_code, interpolations={}
    I18n.t("pform_xml_200." + translation_code.to_s, interpolations)
  end
 
 # format type is either Jquery_time, strftime or timepicker
 def time_format format_type=nil
    #binding.pry
    format =I18n.t("time.formats.default_time_only")
    if format_type=="jquery_time" then
      return strftime_format_2_js_format_simple(format)
    elsif format_type=="strftime" then
      return format
    #elsif format_type=="timepicker" then
      #if format.include?("%l") || format.include?("%k") then 
        #return 'tt'
      #else
        #return ''
      # end    
    else
      return format  
    end
  end
  
end
