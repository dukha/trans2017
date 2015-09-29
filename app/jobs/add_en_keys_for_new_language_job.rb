class AddEnKeysForNewLanguageJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(cavs_translation_language_id)

    begin
      cavtl = CalmappVersionsTranslationLanguage.find(cavs_translation_language_id)
      cavtl.add_all_dot_keys_from_en_for_new_translation_language
    rescue => exception
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> CalmappVersionsTranslationLanguage, :id => cavs_translation_language_id,
        :method => "add_all_dot_keys_from_en_for_new_translation_language"})
        #:data => {:worker => worker.to_s, :queue => queue, :payload => payload})
        
      exception_raised(("Exception in add_all_dot_keys_from_en_for_new_translation_language() " + exception.message), exception.backtrace)
      raise  
    end
    # Do something later
  end
end
