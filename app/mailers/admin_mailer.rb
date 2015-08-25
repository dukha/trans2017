class AdminMailer < ApplicationMailer
  #include ActionView::Helpers::UrlHelper
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.user_invitation_accepted.subject
  #
  def user_invitation_accepted new_user, link
    #binding.pry
    @new_user = new_user#User.find(new_user)
    @admin_user =  User.find(@new_user.invited_by_id)
=begin    
    link = user_edit_url :id =>@new_user.id, :locale => locale
    
    #edit_path  = link_to("Edit  #{@new_user.actual_name}", link)
    #@edit_url = url_for(edit_path)
    url = users_url(locale: locale) #+ "/" +  @new_user.id.to_s + "/edit"
    #This jive is to try to work around copy on right rubbsih which gives a diagnostic....
    url1 = url.dup
    url1.upcase!
    url1 << ("/" +  @new_user.id.to_s + "/edit")
    url1.downcase!
    url2 = url1.html_safe
    @edit_url = url2.dup
    #binding.pry
=end
   @edit_url = link.upcase!
   @edit_url.downcase!  
    mail( 
      to: @admin_user.email,
      subject: ("Invitation Accepted from " + @new_user.actual_name)
      )
  end
  
  def new_contact_from_user contact
    puts contact.description
    @contact = contact
    mails = []
    User.contact_responders.each{ |responder|
      @responder = responder
      mails << mail(
        to: responder.email,
        subject: "New user contact from translator application"
      )
      }
    mails  
  end
end
