class HelpController < ApplicationController
  $APPLICATION_HELP_VIEW_DIR = 'application/help/application/'
   
  def application
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'help.html.md'
  end
  
  def translator
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'translator/help.html.md'
  end
  def translator_objects
    @markdown_file = true 
    render $APPLICATION_HELP_VIEW_DIR + 'translator/help_objects.html.md'
  end
  def translation_process
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'translator/help_process.html.md'
  end
  
  def developer
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'developer/help.html.md'
  end
  
  def role_of_english
    @markdown_file = true
      render $APPLICATION_HELP_VIEW_DIR + 'developer/role_of_english_in_translations.html.md'
  end
  
  def interpolations
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'translator/interpolations.html.md'
  end
  def administrator
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/help.html.md'
  end
  def redis_databases
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/redis_databases/help.html'
  end
  
  def getting_started
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'translator/getting_started_with_translations.html'
  end
  
  def todo
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + '/todo_list.html'
  end
  
  def contents
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + '/help_contents.html'
  end
end