module SearchController 
  
  # sort_list is used by screens that show sorting by clicking on column headers. Generic
  # called sort_list but actually only 1 sort attr is possible. The list is the attr plus direction (ie 2 values in the hash)
  def sort_list  sortable_attr
    sorting = {}
    # Taking care of sql injection again here
    if params[:sort] && sortable_attr.include?(params[:sort]) then
      sorting[:sort] = params[:sort]
    end
    #again taking care of sql injection
    if params[:direction] then
      sorting[:direction] = sort_direction(params[:direction])
    end
    return sorting
  end
  
  # operator_list produces a list of operators in an hash that match the criteria and can be used by squeel
  # searchable_attr are a list of attribtes of the primary model which are searchable. usually accessed from the model like accessible_attr
  def operator_list searchable_attr = {}, criteria_symbols ={}

    operators = {}
    searchable_attr.each{|attr|
      operator_key = attr_2_operator_sym(attr)
      if criteria_symbols.include?(attr) then
        
        if params[operator_key] then
          if not params[operator_key].blank?
            operators[attr]=params[operator_key]
          else
           # should raise an exception 
           #operators[attr]='matches'
           #cannot be matches as this does not work for all data types in db
           operators[attr]='eq'
          end # not params
        else
          # should raise an exception
          #operators[attr]='matches'
          #cannot be matches as this does not work for all data types in db
          operators[attr]='eq'  
        end  # not params
      else
    
        # These criteria are missed in the run through the criteria, so we here add the operator and attr even though there is only an operator
        if operators_that_dont_need_criterion.include?(params[operator_key]) then
          operators[attr] = params[operator_key]
          criterion_key = attr_2_criterion_sym(attr)
          criteria_symbols[attr] = criterion_key
        end # operator does not need criterion
      end  # include?    
    }
    return operators
  end
  
  # criterion_list produces a list of attributes and values in an array that match the operators and can be used by squeel
  # Note that dates will only be processed properly if attr ends with '_date' or _at
  # @param searchable_attr are a hash of attribtes of the primary model which are searchable. usually accessed from the model like accessible_attr
  # @param formats is a hash of formats(primarily dates strftime )  , keyed by criterion where a date is in a format other than default  
  def criterion_list searchable_attr = {}, formats ={}, criteria = {}

    searchable_attr.each{|attr|
      criterion_key = attr_2_criterion_sym(attr)
      #operator_key = attr_2_operator(attr)
      if params[criterion_key] then
        if not params[criterion_key].blank? then
          if criterion_key.to_s.ends_with?('_date') || criterion_key.to_s.ends_with?('_at') then
            # This is  a bit shakey: duck programming at its "best" providing you know ath all date attributes must end with "_date"
            #criteria[attr] = DateTime.strptime(params[criterion_key], ((formats[criterion_key].nil?)?t($DF + "default") : t(formats[criterion_key])))
            criteria[attr] = DateTime.strptime(params[criterion_key], ((formats[criterion_key].nil?)?$DATE_TRANSFER_FORMAT : t(formats[criterion_key])))
          else
            criteria[attr] =params[criterion_key]
          end
        #else
          
              
        end # not blank
      end    
    }
    return criteria
  end
  
   def attr_2_operator_sym attribute
     ("operator_" + attribute).to_sym
  end  
  
  def attr_2_criterion_sym attribute

     ("criterion_" + attribute).to_sym
  end 
  
   #use this function when sorting from the UI to prevent sql injection
  # similar logic may be contained in model if it is a special case like Course
  def sort_direction user_input
    if user_input.nil? then
      ret_val='asc'
    elsif user_input.downcase ==  'desc' then
      ret_val= 'desc'
    else
      ret_val='asc'
    end
    return ret_val
  end
  
  def init_search(current_user, searchable_attr={}, sortable_attr={})
     #searchable_attr = AssistantTeacher.searchable_attr

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    #sortable_attr=AssistantTeacher.sortable_attr
    sorting=sort_list(sortable_attr)
    info = {}
    info[:criteria] = criteria
    info[:operators] = operators
    info[:sorting] = sorting
    info[:messages] =[]
    return info
   end
end