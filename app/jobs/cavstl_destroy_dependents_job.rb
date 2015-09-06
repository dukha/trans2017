class CavstlDestroyDependentsJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(cavs_translation_language_id)

    begin
      cavtl = CalmappVersionsTranslationLanguage.find(cavs_translation_language_id)
      cavtl.destroy_dependents #deep_destroy
    rescue => exception
  
      ExceptionNotifier.notify_exception(exception,
      {:data=> {:class=> CalmappVersionsTranslationLanguage, :id => cavs_translation_language_id}})
        
        info "Exception in deep_destroy() " + exception.message 
        exception_raised
        raise
    end
  end
end
