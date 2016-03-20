class ApplicationController < ActionController::Base
  #require 'translations_helper'
  #include TranslationsHelper
  require File.join(Rails.root, "app", "/helpers" "/translations_helper.rb" )
  include TranslationsHelper

  include SearchController
  include Exceptions
  include SearchHelper
  #include SearchModel
  protect_from_forgery
=begin  
  #Logging exceptions
  if Log4r::logger['rails'].exception?
    rescue_from Exception do |ex| 
      ActiveSupport::Notifications.instrument "exception.action_controller", message: ex.message, inspect: ex.inspect, backtrace: ex.backtrace 
      raise ex  
    end
  end 
=end 
  #before_filter  :set_locale
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_host_from_request
  
  #after_filter :prepare_unobtrusive_flash
  #rescue_from ActiveRecord::RecordInvalid, :with => :record_invalid
  rescue_from ActiveRecord::RecordInvalid do |exception|
    #tflash[:error] = exception.message
    render :action => (exception.record.new_record? ? :new : :edit)
  end
  rescue_from   InvalidBelongsToAssociation do |exception|
      #tflash[:error] = exception.message

      render :action => (exception.record.new_record? ? :new : :edit)
  end
=begin  
  rescue_from ActiveRecord::DeleteRestrictionError do |exception|
    
    flash.now[:error] = exception.message
    redirect_to(:back, :error => exception.message)
  end
=end
  #Rescuing a violation of DB unique constraint
=begin
  rescue_from ActiveRecord::RecordNotUnique do |not_unique|
     message = not_unique.message
    if pgerror? not_unique then
        # We have a postgres non_unique error. This should only happen for multicolumn unique indexes
        # which cannot be properly trapped by active record.
        # We make a translatable more user friendly inde
        
        message.gsub!("PGError:","")
        messages = message.split("\n")
        opening_bracket1_index = messages[1].index("(")
        closing_bracket1_index = messages[1].index(")", opening_bracket1_index )
        opening_bracket2_index = messages[1].index("(", closing_bracket1_index)
        closing_bracket2_index = messages[1].index(")", opening_bracket2_index )

        fieldlist = messages[1][(opening_bracket1_index+1)..(closing_bracket1_index-1)]
        model= nil

        if messages.length > 2 then
          messages[2].downcase!()
          tokens = messages[2].split(" ")
          #tokens[0] should be ':'
          if tokens[1] == 'insert' && tokens[2] == 'into' then
            model=tokens[3].delete("\"").singularize
          elsif
            if tokens[1] == 'update' then
              model= tokens[2].delete("\"").singularize
            end
          end
        end
        #debugger
        translated_fields = fieldlist.split(",").collect{|f| tlabel(f.strip, model)}
        single_value = (translated_fields.split.length == 1)
        if  single_value then
          key_qualifier="non_unique_singlevalue_key."
        else
          key_qualifier="non_unique_multivalue_key."
        end

        #msg= single_value ?  "" : (t("messages." + key_qualifier + "error") + "<br>")
        msg_detail = t("messages." + key_qualifier + "error", :fieldlist=>"(" + translated_fields.join(", ") +")", :valuelist=>messages[1][opening_bracket2_index..closing_bracket2_index])
        user_friendly_message= (msg_detail).html_safe
      else
        user_friendly_message = message
      end
      #user_friendly_message
      #puts user_friendly_message
      flash[:error]= user_friendly_message
      
      render :action => ((messages.length > 2) && (messages[2].index("INSERT INTO"))) ? :new : :edit
      #render :action => "new", :controller => "calmapps"
  end 
=end
  #rescue_from Exception, :with => :rescue_all_exceptions  if Rails.env == 'production'

  
  @markdown_file = false
=begin  
  This method is activated by declarative auth to give a better user experience 
  when the user is denided access by decl_auth 
=end  
#=begin @deprecated
  def permission_denied
    
  flash[:notice] = tmessage("declarative_authorization.unauthorised",  $W )
  redirect_to root_path
end
#=end
  # Is Authorization.current_user the same as current_user???
  #qq before_filter {|contr| Authorization.current_user = contr.current_user}
=begin
This function, together with the scope in routes.rb allows the setting of urls like http://example.com/en/products/1
=end
  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    options[:locale] = I18n.locale 
    if Rails.env.production?
      options[:host] = "trans.calm-int-trans.dhamma.org.au.com"
    end
    options
  end
  def url_options()
    options = {}
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    options[:locale] = I18n.locale 
    if Rails.env.production?
      options[:host] = "trans.calm-int-trans.dhamma.org.au.com"
    end
    options
  end

  def set_locale
    logger.debug "Param locale = " + (params[:locale]==nil ? "nil" : params[:locale].to_s)
    logger.debug "Session locale = " + (session[:locale] ==nil ? "nil" : session[:locale].to_s)
    #binding.pry
    I18n.locale = params[:locale] || session[:locale] || :en #extract_locale_from_accept_language_header
    logger.info "Locale set to " + I18n.locale.to_s
  end
=begin
  This function will fall over if called outside the browser (like in rspec, for example)
=end
  def extract_locale_from_accept_language_header

    logger.info 'HTTP_ACCEPT_LANGUAGE = ' + request.env['HTTP_ACCEPT_LANGUAGE']
     request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    request.env['HTTP_ACCEPT_LANGUAGE'].split(",").first
  end

  def pgerror? exception
    exception.message.start_with? "PGError:"
  end
=begin
 This is all taking too long to do with rake and rabbitmq(bunny). 
   Switching to delayed_job with a  fudge as it doesn't do creates. 
   Have to have an AR before you can do it 
     @deprecated for this version
=end
  def call_rake(task, options = {})
    options[:RAILS_ENV] ||= Rails.env
    
    options["params"] = JSON.generate(params["calmapp_version"])#options.map { |n, v| "#{n.to_s}=#{JSON.generate(v)}}" }
    #puts args 
    args = options.map{ |k,v| "#{k.to_s} = #{v}"  } 
    # add 2>&1 into that command somewhere so that you capture STDERR into your log file as well as STDOUT
    cmd =  "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
    puts cmd
    system cmd 
  end

=begin  
  def after_sign_out_path_for(resource)
    redirect_to new_user_session_path
  end
=end
  def self.start_delayed_jobs_queue
    
    #system "RAILS_ENV=#{Rails.env} bin/delayed_job start --exit-on-complete 2>&1 >> #{Rails.root}/log/background.log"
    system "RAILS_ENV=#{Rails.env} bin/delayed_job start --exit-on-complete 2>&1"
    
  end
=begin
  Use this function to rescue all situations
  Add exception for no
=end
=begin
  def rescue_all_exceptions(exception)
    case exception
      when ActiveRecord::RecordNotFound
        # render :text => "Invalid request", :status => :not_found

      else
        logger.error( "\nWhile processing a #{request.method} request on #{request.path}\n
        parameters: #{request.parameters.inpect}\n
        #{exception.message}\n#{exception.clean_backtrace.join( "\n" )}\n\n" )
        #render :text => "An internal error occurred. Sorry for inconvenience", :status => :internal_server_error
    end
  end
=end
#prodpw +1JzOH2g markslogin
=begin
 def record_invalid(exception)
    flash[:error] = exception.message + " " + exception.record.to_s
  end
=end
 
protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) << [:username, :actual_name, :country, :phone, :email]
    devise_parameter_sanitizer.for(:account_update).flatten
  end
  
 private

    def set_host_from_request
        ActionMailer::Base.default_url_options = { host: request.host_with_port }
    end 
end
