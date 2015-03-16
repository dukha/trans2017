class UserMailer < ApplicationMailer
  default :from => "#{'translator-notifier'} <#{'trans_app@internode.on.net'}>"
  def background_process_fail(user, process_name, object_name, error_message)
    @user = user
    @process_name = process_name
    @error_message = error_message
    @object_name = object_name
    mail(:to => "#{user.username} <#{user.email}>", :subject => "Background Process Fail")
  end
  
  def background_process_success(user, process_name, object_name)
    @user = user
    @process_name = process_name
     @object_name = object_name
    mail(:to => "#{user.username} <#{user.email}>", :subject => "Background Process Success")
  end
end
