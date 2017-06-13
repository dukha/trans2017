Translate::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  #rails 4 remove config.whiny_nils = true
  config.eager_load = false
  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  
  # devise wants this
  #config.action_mailer.default_url_options = { :host => 'localhost:3000' }  
  # config ExceptionNotifier
  config.middleware.use ExceptionNotification::Rack,
      :email =>{
        :email_prefix => Rails.env.humanize + ": Exception] ",
        :sender_address => %{"translator-notifier-dev" <mplennon@optusnet.com.au>},
        :exception_recipients => %w{mplennon@gmail.com}
    }
  # sendmail users the sendmail_settings below
  config.action_mailer.default_url_options = {:host => 'localhost:3000'} 
  #config.action_mailer.delivery_method = :sendmail
=begin  
  # to use google then uncomment the4 line below (It will sue the smtp_settings below)
  #config.action_mailer.delivery_method = :smtp 
  config.action_mailer.perform_deliveries = true 
  config.action_mailer.default :charset => "utf-8" 
  config.action_mailer.raise_delivery_errors = true 
  
  config.action_mailer.sendmail_settings = { 
    :location => '/usr/sbin/exim', 
    # The -t switch doesn't work in the case of devise_invition
    :arguments => '-i -t' 
  }
  #config.action_mailer.delivery_method = :mailgun
  #config.action_mailer.mailgun_settings= {
  #      api_key: Rails.application.secrets.mailgun_api_key, 
  #      domain: Rails.application.secrets.mailgun_domain
  #}
  config.action_mailer.smtp_settings= {
    address: "smtp.gmail.com",
    port: 587,
    domain: Rails.application.secrets.domain_name,
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: Rails.application.secrets.email_provider_username,
    password: Rails.application.secrets.email_provider_password
  }
=end  
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options =  {
    host: 'localhost:3000'
  }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  my_domain = "localhost"
=begin
  config.action_mailer.smtp_settings = {
      :address => "smtp.sparkpostmail.com",
      :port => 587, # ports 587 and 2525 are also supported with STARTTLS
      :enable_starttls_auto => true, # detects and uses STARTTLS
      :user_name => "SMTP_Injection",
      :password => Rails.application.secrets.sparkpost_api_key, # SMTP password is any valid API key
      :authentication => 'login',
      :domain => my_domain, # your domain to identify your server when connecting
      :from => Rails.application.secrets.email_from
  }
=end
  config.action_mailer.smtp_settings = 
          { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => my_domain,
            :user_name            => 'mflennon99',
            :password             => 'salila00',
            :authentication       => 'plain',
            :mail_from => Rails.application.secrets.email_from,
            :enable_starttls_auto => true  }
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  
  config.logger = Logger.new(config.paths['log'].first, 1, 3*1024*1024)
  
  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  # This would configure rails-i18n gem for a limited number of locales
  config.i18n.available_locales = [:en, :nl, :fr, :cs, :th]
=begin
  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
#=end  
  # 3.1 Do not compress assets
  config.assets.compress = false
  # 3.1 Expands the lines which load the assets
  config.assets.debug = true
#=begin  
  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict
  
  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5
=end 
  #Paperclip.options[:command_path] = "/usr/bin/"
end

