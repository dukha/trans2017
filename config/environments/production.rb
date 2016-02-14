Translate::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true
  config.eager_load = true
  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this, so set to false. True only for local testing of production
  config.serve_static_files = false
  #Compress JavaScript and CSS
  config.assets.compress = true
   # Compress JavaScripts and CSS
   config.assets.js_compressor = :uglifier
  # Don't fallback to assets pipeline in prod
  config.assets.compile = false
  # Generate digests for assets URLs
  config.assets.digest = true
  # fro rails 4 apparently
  config.assets.precompile = ['*.js', '*.js.erb','*.css', '*.css.erb']

  config.action_mailer.delivery_method = :mailgun
  # this is foir devise. Must be edited for production
  config.action_mailer.default_url_options = { :host => 'trans.calm-int-trans.dhamma.org.au' }
  config.action_mailer.default :charset => "utf-8" 
  config.action_mailer.raise_delivery_errors = true 

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
  
  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  #rails 4.2 and higher Keep prod log level as info
  config.log_level = :info
  config.action_mailer.mailgun_settings = {
        api_key: Rails.application.secrets.mailgun_api_key,
        domain: Rails.application.secrets.mailgun_domain
  }
  #config.i18n.available_locales = [:en, :nl] #fallback2016
  #config ExceptionNotifier
  config.middleware.use ExceptionNotification::Rack,
      :ignore_crawlers => %w{Googlebot bingbot},
      :email =>{
        :email_prefix => Rails.env.humanize + ": Exception: ",
        :sender_address => %{"translator-notifier-prod" <mplennon@optusnet.com.au>},
        :exception_recipients => %w{mplennon@gmail.com ryan2johnson9@hotmail.com},
        :email_format => :html
    }
end
