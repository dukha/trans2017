#class Users::InvitationsController < Devise::InvitationsController
#This odes not work for {:controller =>  { :invitations => 'users/invitations' }} in routes
require './app/mailers/admin_mailer'
class InvitationsController < Devise::InvitationsController
  include ActionView::Helpers::UrlHelper
  before_filter :configure_permitted_parameters, if: :devise_controller?
  #This works for {:controller =>  { :invitations => 'invitations' }} in routes
  #before_action :authenticate_user!
  #skip_before_action :authenticate_user!, :only => [:edit, :update]
  
  skip_before_filter :authenticate_user!, :only => [:new, :create]
  filter_access_to [:new, :create] #:all
  
  # the views that are found are devise/invitations/new
  # but they are hard to use because the security is too hard
#=begin 
 
  def new

    super
  end
  
  def create
    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    yield resource if block_given?

    if resource_invited
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      respond_with resource, :location => after_invite_path_for(current_inviter)
    else 
      flash_errors(resource)
      respond_with_navigational(resource) { render :new }
    end
 
  end
 
#=end
   def edit
  
      super
   end
  
   def update
    flash.clear
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?
    
    yield resource if block_given?

    if invitation_accepted
      
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message :notice, flash_message if is_flashing_format?
      resource.profiles << Profile.where{name == 'guest'}.first
      flash[:warning] = "When you sign in you will only have guest privilege (you cannot do very much) until an administrator adjusts your account."
      puts "b4 signin"
      
      sign_in(resource_name, resource)
      puts "after signin"
      #url = user_edit_url(resource.invited_by_id)
     # link = link_to("Update User Record", url)
      #link.upcase!
      #link.downcase!
      
=begin      
      begin
        puts "begin send user_invitation_accepted"
        AdminMailer.user_invitation_accepted(resource).deliver_later
        puts "successful user_invitation_accepted"
      rescue Exception => e
        puts "exception in user_invitation_accepted"
        ExceptionNotifier.notify_exception(e,
         :data=> {:message => e.message})
      end
=end 
      puts "about to respond_with resource" 
      respond_with resource, :location => after_accept_path_for(resource)
      puts "could not respond_with resource"
    else
      flash_errors(resource)
      respond_with_navigational(resource){ render :edit }
    end
  end
 


 rescue_from ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid do |exception|
    flash[:error]= format_message exception
    tflash "non_unique_singlevalue_key", :error, invalid_attributes(exception)
    redirect_to new_user_invitation_path
  end
  
  protected
  # @override
  def after_invite_path_for(resource)
    users_path()
  end
  def after_accept_path_for(resource)
    application_help_path
  end
=begin  
  # @override
  def configure_permitted_parameters
    # Only add some parameters
      devise_parameter_sanitizer.for(:accept_invitation).concat [:phone, :actual_name, :username]
    # Override accepted parameters
     #devise_parameter_sanitizer.for(:accept_invitation) do |u|
      #u.permit(:first_name, :last_name, :phone, :password, :password_confirmation,:invitation_token)
      #u.permit(:actual_name, :username, :phone, :password, :password_confirmation, :invitation_token)
  end
=end
  # this is called when creating invitation
  # should return an instance of resource class
  def invite_resource
    
    ## don't skip sending emails on invite
    new_params = invite_params
    new_params["via_invitable"] = true
    resource_class.invite!(new_params, current_inviter) #do |u|
      #u.skip_invitation = true
    #end
  end

  # this is called when accepting invitation
  # should return an instance of resource class
  def accept_resource
     
    resource = resource_class.accept_invitation!(update_resource_params)
    ## Report accepting invitation to analytics
    #Analytics.report('invite.accept', resource.id)
    resource
  end
  
  def configure_permitted_parameters
  # Only add some parameters
  
  devise_parameter_sanitizer.for(:accept_invitation).concat [:actual_name, :email, :username, :country, :phone, :invited_by_id]
  # Override accepted parameters
=begin
  devise_parameter_sanitizer.for(:accept_invitation) do |u|
    u.permit(:first_name, :last_name, :phone, :password, :password_confirmation,
             :invitation_token)
  end
=end
end
  
  private
    def format_message exception
      message = exception.message[/ERROR.*\n.*INSERT INTO/].gsub("\n"," ")
      message = message.gsub(": INSERT INTO","")
      message = message.gsub("ERROR:","")
    end
  
    # return something like {:fieldlist => "username", :valuelist => "abc"}
    def invalid_attributes exception
      uniq_constraint = exception.message[/violates unique constraint /]
      raise exception if uniq_constraint.nil?
      field = "username" if exception.message[/username/]
      field = "email" if exception.message[/email/]
      value = ''
      {:fieldlist => field, :valuelist => value}
    end
    
    def flash_errors(resource)
      resource.errors.each{ |key, msg|
      k = key.to_s
      if flash.empty?
        flash[:error] = (k + ' ' + msg) 
      elsif flash[:error].blank?
        flash[:error] = (k + ' ' + msg)
      elsif flash[:error1].blank? 
      flash[:error1] = (k + ' ' + msg)
     elsif flash[:error2].blank? 
      flash[:error2] = (k + ' ' + msg)
     else
       flash[key.to_s] = k + " " + msg
     end     
      }
    end
end