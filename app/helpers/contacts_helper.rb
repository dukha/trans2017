module ContactsHelper
  def show_user( user)
    html = "<ul id = 'user', style = 'margin-left:25%'>"
    html = html +  "<li>Name: #{user.actual_name}</li>"
    html = html +  "<li>Handle: #{user.username}</li>"
    html = html +  "<li>Email: #{user.email}</li>"
    html = html +  "<li>Country: #{user.country}</li>"
    html = html +  "<li>Phone: #{user.phone}</li>"
    html = html +  "<li>Role(s): #{user.roles_list}</li>"
    html = html +  "</ul>"
    return html.html_safe
  end
end
