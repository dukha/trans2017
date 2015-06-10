class HelpController < ApplicationController
  $APPLICATION_HELP_VIEW_DIR = 'application/help/application/'
  
  def application
    render $APPLICATION_HELP_VIEW_DIR + 'help.html'
  end
  
  def translator
    render $APPLICATION_HELP_VIEW_DIR + 'translator/help.html.erb'
  end
  def translator_objects
    render $APPLICATION_HELP_VIEW_DIR + 'translator/help_objects.html.erb'
  end
  def translation_process
    render $APPLICATION_HELP_VIEW_DIR + 'translator/help_process.html.erb'
  end
  
  def developer
    render $APPLICATION_HELP_VIEW_DIR + 'developer/help.html'
  end
  
  def administrator
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/help.html'
  end
  def redis_databases
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/redis_databases/help.html'
  end
end