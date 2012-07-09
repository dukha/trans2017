module LocationHelper
  def display_location_subtree2(location)
    debugger
    html = "<li>".html_safe
    if location == nil then
      html << " #{t("commons.no_data")} </span>".html_safe
      html << "<ul id=\"children_of_NIL\">".html_safe

    else
      html << ("<table class='treeleaftable'><tr><td class='treeleaftd'>#{t($ARA +"location.type." + location.type)}</td><td 'treeleaftd> <ul class='dropdown-calm'>\n<li><a href='#'>#{location.to_s}</a>").html_safe
      
      html << context_menu(location).html_safe
      html << "</ul></td></tr></table>\n".html_safe
      
      html << "<ul id=\"children_of_#{location.id}\">".html_safe
      location.children.each{|child_location|
          html << display_location_subtree2( child_location)
      }
    end #location nil?e
    # end the child node
    html << "</ul>".html_safe
    # end of list item which contained the child
    html << "</li>".html_safe
    #html = html.html_safe
    return html
  end
  
  # This function gives a dropdown menu for each node of the tree with the correct options for each user.
  # Could be further simplified by making calls to link_menu but this here is neat enough, I think.
  def context_menu(location)
    html=''
    html << "<ul class='context-sub-menu'>\n"
      if permitted_to? :edit, location then
             html << ("<li>" + tlink_to('edit', edit_location_path(location), :method => :get, :model=>location.name)+ "</li>\n")
      end 
      if location.deletable? and permitted_to? :destroy, location then
        html << ( link_destroy(location, location.type.to_sym,{:category=>'menu'}, 'li'))
        #tlink_to("delete", location_path(location), :method => :delete, :confirm => "delete.are_you_sure", :model=>location.name, :value=>location.to_s) +"</li>\n")
      end
      if location.class.name != "Venue" then
        if location.allow_area_child? and permitted_to? :create, Area.new then
          html << ("<li>" + tlink_to( "add_area", new_child_area_path(location), :method => :get, :model=>location.name) + "</li>\n")
        end 
=begin 
        if location.allow_venue_child? and permitted_to? :create, Venue.new then
          #debugger
          link = tlink_to("add_venue", new_child_venue_path(location), :method => :get, :model=>location.name) 
          html << ("<li>"  + link + "</li>\n")
        end
=end
        if location.allow_organisation_child? and permitted_to? :create, Organisation.new then
          html << ("<li>" + tlink_to("add_organisation",new_child_organisation_path(location), :method => :get, :model=>location.name) + "</li>\n")
        end
        if location.allow_server_child? and permitted_to? :create, Server.new then
          html << ("<li>" + tlink_to("add_server",new_child_server_path(location), :method => :get, :model=>location.name) + "</li>\n")
        end
      else
        # todo add a url to list current courses at venue 
      end # not venue
      #todo: :model=>location.name  is that correct?
      #todo: if permitted
      #todo: location_variable should be nested into location, location variable renamed to variable?
      #html << ("<li>" + tlink_to('letters', location_location_variables_path(location), :method => :get, :model=>"location_variable")+ "</li>\n")
      html << "</ul>"
      return html.html_safe
  end
end