class PublishLanguageToRedisJob < ActiveJob::Base
  queue_as :default

  def perform(calmapp_version_id, translation_language_id)

    begin
      # c
      #tu = TranslationsUpload.find(translations_upload_id)
      #tu.write_yaml()
      RedisDatabase.version_language_publish(calmapp_version_id, translation_language_id)  
    rescue => exception
  
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> RedisDatabase, :version => CalmappVersion.find(calmapp_version_id).show_me, :language => TranslationLanguage.find(translation_language_id).name })
        #:data => {:worker => worker.to_s, :queue => queue, :payload => payload})
        #:data => { :queue => queue, :payload => payload})
        puts "Exception in version_language_publish()"
        raise
    end
    # Do something later
  end
end
