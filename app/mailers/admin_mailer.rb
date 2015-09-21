class AdminMailer < ApplicationMailer
  include ActionView::Helpers::UrlHelper
  
  def user_invitation_accepted new_user
    puts "ACTION_MAILER"
    @new_user = new_user#User.find(new_user)
    puts @new_user.email.to_s
    @admin_user =  User.find(@new_user.invited_by_id)
    puts "ADMIN USER = " + @admin_user.email.to_s
    url = user_edit_url(@new_user.id, :locale=> locale)
    @link = link_to("Edit New User", url )
    puts "INSIDE ADMIN_MAILER"
    puts url
    puts @link
   
    mail( 
      to: @admin_user.email,
      subject: "Vipassana Translator Invitation Accepted by #{@new_user.actual_name}"
      )
  end
  
  def new_contact_from_user contact_id, responder_id
    #puts contact.description
    @contact = Contact.find(contact_id)
    #@requesting_user = User.find(@contact.user)
    @responder = User.find(responder_id)
    
    @link = link_to("Contact", edit_contact_url(@contact.id, locale: locale)).html_safe
    mail(
      to: @responder.email,
      subject: "Reply to Contact from Vipassana Translator"
      )
  end
  
  def notify_user_permissions_assigned_after_invitation(user_id)
    @user = User.find(user_id)
    @admin = User.find(@user.invited_by_id)
    @signin_url = new_user_session_url(:locale => locale)
     mail(
        to: @user.email,
        subject: "Welcome to Vipassana Translator"
      )
  end
end
