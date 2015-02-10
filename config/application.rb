require File.expand_path('../boot', __FILE__)

require 'rails/all'
=begin
#log4r requirements
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
include Log4r
=end

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
#puts Bundler.require
#puts Rails.env
#Bundler.require(:default, "config/environments/" + Rails.env) if defined?(Bundler)
=begin
if defined?(Bundler)
  # If you precompile assets before deploying to production,
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production,
  #  use this line instead
  # Bundler.require(:default, :assets, Rails.env)
end  
=end
Bundler.require(:default, Rails.env)
    
module Translate
  #attr_accessor :max_redis_databases
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
    config.i18n.default_locale =  "en" #.to_sym
    log = Logger.new(STDOUT)
    # !! log.info "def locale : " + config.i18n.default_locale.to_s
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    config.generators do |g|
      g.test_framework :rspec
    end
    config.autoload_paths += %W(#{config.root}/lib/)
    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types.
    # The other choice is :ruby which is default.
    # Configuring :sql means that for postgres, the schema will be created by pg_dump
    config.active_record.schema_format :sql
    # set this to false whilst transitioning to rails 4
    #config.active_record.whitelist_attributes=false  
    # 3.1 Enable the asset pipeline
    config.assets.enabled = true
=begin
    # 3.1 Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
=end
    #Put in to take are of a "stack too deep bug introduced in rails 3.1.5"Put in to take are of a "stack too deep bug introduced in rails 3.1.5"
    config.assets.initialize_on_precompile = false
    # rails logger
    # config.logger = ActiveSupport::Logger.new('your_app.log')
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new("log/#{Rails.env}.log"))
    #config.log_tags = [ lambda { |req| user = req.env['warden'].user; user && user.name || 'Unknown'; }]

=begin    
      # assign log4r's logger as rails' logger.
    log4r_config= YAML.load_file(File.join(File.dirname(__FILE__),"log4r.yml"))
    log_cfg = YamlConfigurator
    log_cfg["ENV"] = Rails.env 
    log_cfg["EC2_INSTANCE"] = ENV["EC2_INSTANCE"].nil? ? `hostname`.to_s.gsub(/\n$/, "") : ENV["EC2_INSTANCE"] 
    log_cfg["APPNAME"] = Rails.application.class.parent_name
    log_cfg.decode_yaml( log4r_config['log4r_config'] )
   
    config.logger = Log4r::Logger['rails']
    config.log_level = DEBUG
    ActiveRecord::Base.logger = Log4r::Logger['rails']
    ActiveRecord::Base.logger = Log4r::Logger['postgres']
    
    # disable standard Rails logging
    config.log_level = :unknown
    # disable ActiveRecord logging
    ActiveRecord::Base.logger = Logger.new('/dev/null')
=end
  end


end
