class AdminMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.user_invitation_accepted.subject
  #
  def user_invitation_accepted new_user

    @new_user = new_user#User.find(new_user)
    @admin_user =  User.find(@new_user.invited_by_id)
    
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
