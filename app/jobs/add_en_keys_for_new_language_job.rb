class AddEnKeysForNewLanguageJob < ActiveJob::Base
  queue_as :default

  def perform(cavs_translation_language_id)
    #binding.pry
    begin
      cavtl = CalmappVersionsTranslationLanguage.find(cavs_translation_language_id)
      cavtl.add_all_dot_keys_from_en_for_new_translation_language
    rescue => exception
      puts "Exception in add_all_dot_keys_from_en_for_new_translation_language()"
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> CalmappVersionsTranslationLanguage, :id => cavs_translation_language_id})
        #:data => {:worker => worker.to_s, :queue => queue, :payload => payload})
      raise  
    end
    # Do something later
  end
end
