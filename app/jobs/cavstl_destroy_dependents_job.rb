class CavstlDestroyDependentsJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(cavs_translation_language_id)

    begin
      cavtl = CalmappVersionsTranslationLanguage.find(cavs_translation_language_id)
      cavtl.destroy_dependents #deep_destroy
    rescue => exception
  
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> CalmappVersionsTranslationLanguage, 
        :id => cavs_translation_language_id, :method=>"destroy_dependents"})
        
       
        exception_raised(("Exception in deep_destroy() " + exception.message), exception.backtrace)
        raise
    end
  end
end
