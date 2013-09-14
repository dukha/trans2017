=begin
module ProfilesHelper
  
  def layout_check_boxes profile
    html =''
    rows_data= collect_roles_in_groups
    #puts "bbbb " + collect_roles_in_groups.to_s
    if ! rows_data.empty? then
      html << "<table>"
      rows_data.each { |array|
        html << "<tr>"
        
        html << "<td class='profilerowheader'>"
        if array == rows_data.last then
          html<< t("roles.miscellaneous")  
        else
          arr=array.first.to_s.split("_")
          html << t("roles." + arr[0..(arr.length)-2].join("_"))
        end

        html << "</td>"
        array.each{ |role|
        html << "<td class='profilecheckboxtd'>"
        html << check_box_tag("profile[roles][]", role, profile.roles.include?( role), :class=>"profilecheckbox")
        if array==rows_data.last then
          html << label_tag(role, t("roles." + role.to_s)) #t("."+role.to_s))
        else
          label = role.to_s.split("_").last
          html << label_tag(role, t("roles.actions." + label))
        end
        html << "</td>"
          
        }  
      html << "</tr>\n"
      }
    end
    html<< "</table>"
    return html.html_safe
  end
  
  def collect_roles_in_groups
    #puts Profile.available_roles
    roles=Profile.available_roles.sort{ |r,s |
      r.to_s <=> s.to_s}
    #puts "cccc " + roles.to_s  
    previous_resource=nil
    remember_resource=nil
    all_arrays = []
    current_array = []
    misc_array=[]
    roles.each{ |role|
        split=role.to_s.split('_')
       # puts "dddd " + split.to_s
       # puts"\n"
        #puts split.last
        #puts %w(read write create destroy).include?(split.last)
        #puts "\n"
        role_resource= split[0..(split.length-2)].join('_')
        # puts role_resource
        if %w(read write create destroy).include?(split.last) then
          #puts split.last + " included"
          # "nil " + previous_resource.nil?.to_s
          if role_resource == previous_resource || previous_resource.nil? then
            
            # puts "role rs = prev rs or previs nil " + role.to_s
            add_role_to_array(current_array, split.last, role)
          else
            
            all_arrays << current_array
            current_array = []
            add_role_to_array(current_array, split.last, role)
            # puts "finish " +current_array.to_s
            # puts "all " + all_arrays.to_s 
            
            # current_array << role
            
          end
          previous_resource=role_resource
          #current_array<<role
        else
          #puts "not " + "read write create destroy " +role.to_s
          #puts "rem " + remember_resource.to_s
          #puts "prev " + previous_resource.to_s
          #if remember_resource == role_resource then
            #puts "add extra " + role
            #This is necessary for the case where we have 5 or more roles for 1 resource, e.g location_read, *_write, *_create, *_destroy, *_treeview
            #current_array.insert(4,role)
          #else
            #puts "remember = " +remember_resource.to_s
            #puts "previous = " + previous_resource.to_s
            #puts "remember not = role add to misc " +role.to_s
          role_resource=role
          misc_array << role
            #previous_resource = role
            #remember_resource = role
          #end  
        end  
    }  
    all_arrays<< current_array
    all_arrays << misc_array
    #puts all_arrays
    return all_arrays
  end  
  
  def add_role_to_array array, suffix, role
    if (suffix=='read') then
      array[0] = role
      puts "added read to " +role.to_s
    elsif suffix=="write" then
      array[1] = role 
      puts "added write to " +role.to_s
    elsif suffix=="create" then
      array[2] = role
      puts "added create to " +role.to_s
    elsif suffix=='destroy' then
      array[3] = role   
      puts "added destroy to " +role.to_s  
    end  
  end
end
=end
module ProfilesHelper
  STANDARD_ACTIONS = %w(read write create destroy)
  # These must all be in the translation file as roles.<action>
  NONSTANDARD_ACTIONS = %w(lookup confirm template addallocations search letters import change trafficlightchange invite)
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
        end

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
        }  # end each
      html << "</tr>\n"
      }
    end
    html<< "</table>"
    #binding.pry
    return html.html_safe
  end
  
  def collect_roles_in_groups
 
    roles=Profile.available_roles.sort{ |r,s |
      r.to_s <=> s.to_s
    } 
    previous_resource=nil
    all_arrays = []
    current_array = []
    misc_array=[]
    roles.each{ |role|
        tokens=role.to_s.split('_')
    
        role_resource= tokens[0..(tokens.length-2)].join('_')
        #if %w(read write create destroy lookup confirm template addallocations search letters ).include?(tokens.last) then
        if (STANDARD_ACTIONS + NONSTANDARD_ACTIONS).include?(tokens.last) then
          if role_resource == previous_resource || previous_resource.nil? then
            add_role_to_array(current_array, tokens.last, role)
          else 
            all_arrays << current_array
            current_array = []
            add_role_to_array(current_array, tokens.last, role)            
          end
          previous_resource=role_resource
          #current_array<<role
        else
          role_resource=role
          misc_array << role
        end  
    }  
    all_arrays<< current_array
    all_arrays << misc_array
    return all_arrays
  end  
  
  def add_role_to_array array, suffix, role
    if (suffix=='read') then
      array[0] = role
      #puts "added read to " +role.to_s
    elsif suffix=="write" then
      array[1] = role 
      #puts "added write to " +role.to_s
    elsif suffix=="create" then
      array[2] = role
      #puts "added create to " +role.to_s
    elsif suffix=='destroy' then
      array[3] = role   
      #puts "added destroy to " +role.to_s 
    #elsif 'lookup confirm template addallocations search letters import change trafficlightchange'.split(' ').include?(suffix) then
    elsif NONSTANDARD_ACTIONS.include?(suffix) then
      max_index= array.index(array.last)
      if !max_index.nil? && max_index > 4 then 
        array.push(role)
      else
        array.insert(4, role)
      end    
    end  
  end
  
  private
    def first_not_nil_element_array array
      #puts "in not nil "
      ret_val=nil
      array.each{ |el|
        #puts "in each " + el.to_s
        #binding.pry
        next if el.nil?
        ret_val = el        
        break   
      }
      return ret_val
    end
end