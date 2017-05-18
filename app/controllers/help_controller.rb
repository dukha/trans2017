class HelpController < ApplicationController
  $APPLICATION_HELP_VIEW_DIR = 'help/application/'
   
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
  
  def user_admin
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/user_admin.html'
  end
  
  def admin_getting_started
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/admin_getting_started.html'
  end
  
  def admin_applications_versions_languages
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/applications_versions_languages.html'
  end

  def uploading
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/uploading.html'
  end
  
  def publishing
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/publishing.html'
  end  
  def translatorpublishing
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'translator/translator_publishing.html'
  end 
  
   def administrator_publishing
    @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/administrator_publishing.html'
  end 
  def contents
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + '/help_contents.html'
  end
  
  def translator_ui
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'translator/translator_ui.html'
  end
  
  def deep_delete
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/deep_delete.html'
  end
  def deep_copy
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/deep_copy.html'
  end
  def background_processes
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'background_processes.html'
  end
  def prerequisites
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'prerequisites.html'
  end
  def admin_workflow
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/workflow.html'
  end
  
  def redis_instances
     @markdown_file = true
    render $APPLICATION_HELP_VIEW_DIR + 'administrator/redis_instances.html'
  end
  
  def developers_english
   @markdown_file = true
  render $APPLICATION_HELP_VIEW_DIR + 'developer/developers_english.html'
  end
  def redis_installation
    @markdown_file = true
  render $APPLICATION_HELP_VIEW_DIR + 'developer/redis_installation.html'
  end
end