class CheckAllEnKeysAvailableInNewLangJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(cavs_translation_language_id)
    #binding.pry
    begin
      CalmappVersionsTranslationLanguage.find(cavs_translation_language_id).check_en_keys_available_in_new_lang#(cavs_translation_language_id)
      puts "Successfully completed " + self.class.name + " cavtl = " + CalmappVersionsTranslationLanguage.find(cavs_translation_language_id).description
    rescue => exception
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> CalmappVersionsTranslationLanguage, :id => cavs_translation_language_id,
        :method => "check_all_en_keys_available_in_new_lang"})
        #:data => {:worker => worker.to_s, :queue => queue, :payload => payload})
        
      exception_raised(("Exception in check_all_en_keys_available_in_new_lang() " + exception.message), exception.backtrace)
      raise  
    end
    # Do something later
  end
  
   
end