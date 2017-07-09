class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
   def create
     #puts "sessioon create"
     super
     #puts 'xxx'
     #puts params
     #puts current_user.usernames
     if integer?(params["tzo"])
       current_user.timezone_offset = params["tzo"]
     else
        Rails.logger.warn("Could not set timezone offset in creation of session for " + current_user.username + " with tzo = " + params["tzo"]) 
     end
     #even if tzo is not in it will use the default anyway
     if ! current_user.save!
        put5 "Error in setting tzo"
     end
     puts current_user.timezone_offset.to_s
   end
private   
   
   def integer?(str)
    /\A[+-]?\d+\z/ === str
   end
  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
=begin
def integer? x
  true if Integer(x) rescue false
end


=end