class CavstlDestroyDependentsJob < ActiveJob::Base
  queue_as :default

  def perform(cavs_translation_language_id)

    begin
      cavtl = CalmappVersionsTranslationLanguage.find(cavs_translation_language_id)
      cavtl.deep_destroy
    rescue => exception
  
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> CalmappVersionsTranslationLanguage, :id => cavs_translation_language_id})
        #:data => {:worker => worker.to_s, :queue => queue, :payload => payload})
        #:data => { :queue => queue, :payload => payload})
        puts "Exception in deep_destroy()"
        raise
    end
    # Do something later
  end
end
