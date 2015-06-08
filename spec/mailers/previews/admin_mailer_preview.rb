# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/user_invitation_accepted
  def user_invitation_accepted
    AdminMailer.user_invitation_accepted
  end

end
