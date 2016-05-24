class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
   def create
     puts "sessioon create"
     super
     puts 'xxx'
     puts params
     puts current_user.username
     current_user.timezone_offset = params["tzo"]
     if ! current_user.save!
       puts "Error in setting tzo"
     end
     puts current_user.timezone_offset.to_s
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
