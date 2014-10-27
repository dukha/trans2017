source 'http://rubygems.org'
#gem 'sass-rails', '~>4.0.0' #:git=> "git://github.com/rails/sass-rails"#, " ~> 3.2.5"
  #gem 'coffee-rails', '~>4.0.0'#, "~> 3.2.1"
  #gem 'uglifier','~>2.2.1'
 
gem 'rails', '~>4.0.0'#'~>3.2.8'

# postgresql connector
gem 'pg'#, '~>0.12.2'

# layout of all forms
gem 'formtastic'#, '1.2.3'

# used for layout only of application
gem 'nifty-generators'#, '0.4.6'

# authentication
gem 'devise'#, '~>2.0.4' 
gem 'devise_invitable'#, '~> 1.3.4'
# this gem is a ruby mailhandler that will work with exim or sendmail (and others). Tested on exim4. 
gem 'mail'# rails 4 depends on 2.5.4 , '~>2.6.1'

#gem 'ruby-gmail'
#xml parser
gem 'nokogiri'#, '1.5.0'

# json parser
gem 'json'

# authorisation No authorization solution compatible with rails 4: CanCan looks closest
gem 'declarative_authorization', :git => "git://github.com/stffn/declarative_authorization.git" #, '0.5.3'

# paginate all index views

gem 'will_paginate','~>3.0.4'

# rails 4 use this gem until you have implemented strong params
#gem 'protected_attributes'

# using jquery for ajax, not prototype > rails g jquery:install
gem 'jquery-rails'#, '~>1.0.12' #, '0.2.7'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

#helps with I18n not used at present. We need to use it to get pagination in the urls, I think
gem 'routing-filter', '0.4.0.pre'


# acts as tree provides access to parents and children without coding more than parent_id (i.e. no has_many needed)
gem 'acts_as_tree'#,'0.1.1'

=begin
 haml contains sass
 to start sass to automatically update calm.scss (when you save calm.scss) to donotedit/calm.css
 $>sass --watch calm.scss:donotedit/calm.scss
=end
#gem 'haml', '3.0.25'
# converts ruby objects to js objects
#gem 'lucy', '0.2.1'
=begin
 depends on lucy. Allows you to use rails translations in js
 e.g. I18n.t('activerecord.errors.template.header', {count:4, model:'pony'}) // "4 errors prohibited this pony from being saved"
 It makes a locales.js file in the default javascripts directory.
 This file contains a copy of all translations in the application
 Beware of including the faker gem as this has lots of translation files: you'll be getting lots of garbage translations in real locales that you don't want
=end
#gem 'babilu', '0.2.2'
# paperclip uploads a file and writes the file name etc to the database
#gem 'paperclip'#, '2.3.11'
gem 'carrierwave'

gem "redis" #, :git => "git://github.com/ezmobius/redis-rb.git"

# Can be used to set up an interface for rabbitmq
#gem "bunny"
# runs long running jobs in background
gem 'delayed_job_active_record'
gem 'daemons'
# foreigner is a gem that allows the insertion of foreign keys into migrations.
# Doesn't work with automigrate. Too bad.
#gem "foreigner"
# for 3.1
gem 'execjs'
gem 'therubyracer'
# in place editing
gem 'best_in_place',  :git => "git://github.com/bernat/best_in_place"

# for doing searches with criteria. Replaces meta_where for rails 3.1
gem 'squeel'

gem 'passenger' #, '~>3.0.11'

# nested forms
gem 'cocoon','~>1.2.0'
# thin is a faster dev webserver than webrick
#gem 'thin'
# web server used in pace of webrick or thin but also in production
gem 'puma'
# email notification of exceptions (if sendmail is installed)
gem 'exception_notification' #_rails3', :require => 'exception_notifier'

gem 'rails-i18n', '~>4.0.0'

#gem 'log4r', :git => "git://github.com/colbygk/log4r"
gem 'logging'
# allows for easy showing of flash even for ajax requests
gem 'unobtrusive_flash', '>=3'

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

  # will document model according to migrations (actually according to schema)
  #gem 'annotate-models', '1.0.4'
  gem 'annotate'
  # Pretty printed test output
  gem 'turn', '~>0.9.6', :require => false
  
  #gem 'activerecord_deprecated_finders'
=begin
 debug that works with ruby 1.9
 place
 debugger
 in code to create breakpoint
 start webrick >rails s --debugger
 then use list, p(rint) var_name, step, next( same as step except skips functions),
c(ontinue) etc to look at code at breakpoint break to set a breakpoint, where for stack, restart,
display/undisplay
=end

  #gem 'ruby-debug19', '0.11.6'
  
  # =============  debugging tools
  # to set breakpoint add line:  binding.pry
  # more at http://pry.github.com/
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-nav'

  # watchr runs rspec, similar to autotest
  #gem 'watchr'
  #gem 'webrat'#,'0.7.3'

=begin
 generate test data
 exclude faker except when you need to use it as it will turn up lots of fake locales and translations in:
  1. locales.js (via babilu)
  2. rake i18n:missing translations
=end
  #gem 'faker'
  
  # generate test data
  gem 'factory_girl_rails', '~> 4.4.0'

end # end group dev, test


  gem 'sass-rails', '~>4.0.0' #:git=> "git://github.com/rails/sass-rails"#, " ~> 3.2.5"
  #gem 'coffee-rails', '~>4.0.0'#, "~> 3.2.1"
  gem 'uglifier','~>2.2.1'

group :test do
  gem 'shoulda-matchers'#, '~>2.6.0'
  gem 'guard-rspec'
  gem 'libnotify', '0.8.0'
  gem 'spork-rails'#, '~> 0.9.0'
  gem 'guard-spork', '1.5.0'
  gem 'childprocess', '0.3.6'
end
group :development do
  gem 'capistrano'
  
  # better display of exception stuff
  gem 'better_errors'
  # allows display of variables etc by better_errors
  gem 'binding_of_caller'
  # works with RailsPanel app in chrome (when installed) to display request info
  gem 'meta_request'
end
