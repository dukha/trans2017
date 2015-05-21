source 'http://rubygems.org'
gem 'rails', '~>4.2.0'#'~>3.2.8'
# postgresql connector
gem 'pg'#, '~>0.12.2'
# layout of all forms
gem 'formtastic'#, '1.2.3'

# authentication
gem 'devise'
gem 'devise_invitable'
# this gem is a ruby mailhandler that will work with exim or sendmail (and others). Tested on exim4. 
gem 'mail'
#gem 'ruby-gmail'
#xml parser
gem 'nokogiri'#, '1.5.0'

# json parser
gem 'json'
gem 'gon'
# authorisation No authorization solution compatible with rails 4: CanCan looks closest
gem 'declarative_authorization', :git => "git://github.com/stffn/declarative_authorization.git" #, '0.5.3'

# paginate all index views

gem 'will_paginate','~>3.0.4'

# rails 4 use this gem until you have implemented strong params
#gem 'protected_attributes'

# using jquery for ajax, not prototype > rails g jquery:install
gem 'jquery-rails'#, '~>4.0.1' 
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'

#helps with I18n not used at present. We need to use it to get pagination in the urls, I think
gem 'routing-filter'#, '0.4.0.pre'


# acts as tree provides access to parents and children without coding more than parent_id (i.e. no has_many needed)
#gem 'acts_as_tree'#,'0.1.1'


gem 'carrierwave'

gem "redis" #, :git => "git://github.com/ezmobius/redis-rb.git"

# Can be used to set up an interface for rabbitmq
#gem "bunny"
# runs long running jobs in background
gem 'delayed_job_active_record'
gem 'daemons'

gem 'execjs'
gem 'therubyracer'
# in place editing
gem 'best_in_place', '~> 3.0.1' #:git => "git://github.com/bernat/best_in_place"

# for doing searches with criteria. Replaces meta_where for rails 3.1
gem 'squeel'

gem 'passenger' #, '~>3.0.11'

# nested forms
gem 'cocoon','~>1.2.0'

# web server used in pace of webrick or thin but also in production
gem 'puma'
# email notification of exceptions (if sendmail is installed)
gem 'exception_notification' #_rails3', :require => 'exception_notifier'

gem 'rails-i18n', '~>4.0.0'


#gem 'log4r', :git => "git://github.com/colbygk/log4r"
gem 'logging'
# allows for easy showing of flash even for ajax requests
gem 'unobtrusive_flash', '~>3'
# needed for rails 4.2 apparently
gem 'responders', '~> 2.0'
# allows a connection pool for redis. Not sure if needed
gem 'connection_pool'

group :development, :test do
  gem 'rspec-rails'#, '2.8.0'
  # webrat or capybara can be used to simulate a browser. rspec doesn't care which one.
  gem 'capybara'#, :git =>'git://github.com/jnicklas/capybara.git'
  #gem 'webrat','0.7.3'
 # gem 'cucumber'
  #gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'shoulda'
  
  gem 'launchy'
  gem 'autotest'#, '4.4.6'
    # rspec advises not to install autotest-rails (but says nothing about autotest-rails-pure). rspec advises only autotest
  gem 'autotest-rails-pure'#,'4.1.2'
  # test server for rspec


  # Pretty printed test output
  #gem 'turn'#, '~>0.9.6', :require => false


  # =============  debugging tools
  # to set breakpoint add line:  binding.pry
  # more at http://pry.github.com/
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-nav'
  gem 'pry-stack_explorer'
  # generate test data
  gem 'factory_girl_rails', '~> 4.4.0'

end # end group dev, test


  gem 'sass-rails', '~>5.0.0' #:git=> "git://github.com/rails/sass-rails"#, " ~> 3.2.5"
  #gem 'coffee-rails', '~>4.0.0'#, "~> 3.2.1"
  gem 'uglifier','~>2.2.1'
  gem 'web-console', '~> 2.0'

group :test do
  gem 'shoulda-matchers'#, '~>2.6.0'
  gem 'guard-rspec'
  gem 'libnotify', '0.8.0'
  gem 'spork-rails'#, '~> 0.9.0'
  gem 'guard-spork', '1.5.0'
  gem 'childprocess', '0.3.6'
end
group :development do
  gem 'capistrano', '3.2.1', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'rvm1-capistrano3', require: false
end
