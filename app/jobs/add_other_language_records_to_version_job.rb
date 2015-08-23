class AddOtherLanguageRecordsToVersionJob < ActiveJob::Base
  queue_as :default

  def perform(translation_id)
    begin
      t = Translation.find(translation_id)
      t.add_other_language_records_to_version
    rescue => exception
      puts "Exception in add_other_language_records_to_version()"
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> CalmappVersionsTranslationLanguage, :id => cavs_translation_language_id})
        #:data => {:worker => worker.to_s, :queue => queue, :payload => payload})
      raise  
    end
  end
end