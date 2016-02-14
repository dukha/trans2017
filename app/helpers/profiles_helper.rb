module ProfilesHelper
  STANDARD_ACTIONS = %w(read write create destroy)
  # These must all be in the translation file as roles.<action>
NONSTANDARD_ACTIONS = %w(lookup confirm search import change invite getunused getnextindex publish languagepublish versionpublish translatorpublish invite unlock redisdbalter translate develop deepcopy deepdestroy  visit deepcopyparams start stop restart)
  def layout_check_boxes profile
    html =''
    rows_data_hashes_array= collect_roles_in_groups
    #each hash
    if ! rows_data_hashes_array.empty? then
      html << "<table class='profiles-form'>"
  
      rows_data_hashes_array.each { |roles_hash|
        next if roles_hash.empty?
        #if ! roles_hash['guest'].nil?
      
        #end
        html << "<tr class = '" + cycle('dataeven', 'dataodd') + "' >"
        
    
        html << "<td class='profilerowheader'>"
        key = roles_hash.keys[0]
        #if key == 'guest'
      
        #end
        if roles_hash == rows_data_hashes_array.last then
          html<< t("roles.miscellaneous")  
        else
      
          translation_code = "roles." + key
          html << t(translation_code)  
=begin
          sym = first_not_nil_element_array(roles_symbols_hash) 
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
=end
        
        end #if symbols arr not last

        html << "</td>"
    
        #roles_symbols_array.each{ |role|
        roles_hash[key].each{ |action|
      
          
          html << "<td class='profilecheckboxtd'>"
          role = role_for( key, action)
          if not action.nil? then
            if key == 'misc'#action.blank? then
              #html << check_box_tag("profile[rools][]", action, profile.roles.include?(role), :class=>"profilecheckbox")
          
              html << one_check_box_html(action, role, profile)
              #t("roles." + key))
            else
              #html << check_box_tag("profile[rools][]", role, profile.roles.include?(role), :class=>"profilecheckbox")
              html << one_check_box_html(role, role, profile)
              #if role == :guest
          
              #end
             # html << label_tag(action, t("roles.actions." + action))
            end
            translation_key = ((action.nil?)?(role.to_s):(action.to_s))
            html << label_tag(key, t("roles.actions." + translation_key))
        
            #if roles_symbols_array==rows_data.last then
               #t("."+role.to_s))
            #else
            
              #label = role.to_s.split("_").last
             
              #html << label_tag(role, t("roles.actions." + label))
            #end
          end
          html << "</td>" 
        }  # end each
      html << "</tr>\n"
      } # each
      html<< "</table>"
    end #rows not empty
    return html.html_safe
  end
  
  def one_check_box_html value, role, profile
    check_box_tag("profile[rools][]", value, profile.roles.include?(role), :class=>"profilecheckbox")
  end
  
  def role_for resource, action
    if action.blank? then
      return resource.to_sym
    end  
      return (resource + '_' + action).to_sym
  end


  
  def collect_roles_in_groups
    previous_resource=nil
    all_hashes = []
    misc_array=[]
    roles_hash = roles_2_hash_of_arrays() 
    #previous_resource = arrange_roles(roles_hash, previous_resource, all_hashes,  misc_array)
    arrange_roles(roles_hash, previous_resource, all_hashes,  misc_array)
    #all_hashes << current_array
    all_hashes << {"misc" => misc_array}
    return all_hashes
  end

  def roles_2_hash_of_arrays()
    prefixes = []
    roles_hash ={}
    i=0
    Profile.available_roles.each do |r|
      rx = r.to_s.split('_')
      if rx.length > 1 then
        prefix = rx[0..rx.length-2].join('_')
        action = rx[rx.length-1]
      else
        prefix = rx[0]
        action = ''
      end # length
      if not roles_hash.include? prefix then
        roles_hash[prefix] = []
      end
      roles_hash[prefix] << action
      i=i+1  
    end #avail roles each
    return roles_hash
  end
  
  def arrange_roles(roles_hash, previous_resource, all_hashes,  misc_array)
    current_action_array = []
    keys = roles_hash.keys.sort
    keys.each do |key|
      # keys are resource names
      role_resource = key
      #if not(role_resource == previous_resource || previous_resource.nil?)  then
        # We are changing resources, so put the old resource into the accumulation and start a new resource
        all_hashes <<{key => []}#current_action_array}
        #current_action_array = []
      #end
      actions = roles_hash[key]
      actions.each do |act|
        role = ((act.blank?) ? key : (key + "_" + act))
        act = role if act.blank?
        if (STANDARD_ACTIONS + NONSTANDARD_ACTIONS).include?(act) then
          add_action_to_array(all_hashes.last[key], key, act)#roles_hash[key], role )
          #previous_resource = role_resource
        else
          #previous_resource = role
          #role = role_resource
          role_resource = role #previous_resource
          misc_array << role
        end # standard and nonstandard
      end #each action
      
    end #each key
    #return previous_resource
  end
  
  def add_action_to_array array, resource, action
    action = '' if action.nil?
    if (action=='read') then
      array[0] = action
      #puts "added read to " +resource.to_s
    elsif action=="write" then
      array[1] = action 
      #puts "added write to " +resource.to_s
    elsif action=="create" then
      array[2] = action
      #puts "added create to " +resource.to_s
    elsif action=='destroy' then
      array[3] = action   
      #puts "added destroy to " +resource.to_s 
    #elsif 'lookup confirm template addallocations search letters import change trafficlightchange'.split(' ').include?(action) then
    elsif NONSTANDARD_ACTIONS.include?(action) then
      max_index= array.index(array.last)
      if !max_index.nil? && max_index > 4 then 
        array.push(action)
      else
        array.insert(4, action)
      end    
    end  
  end
  
  private
    def first_not_nil_element_array array
      ret_val=nil
      array.each{ |el|
        next if el.nil?
        ret_val = el        
        break   
      }
      return ret_val
    end
end