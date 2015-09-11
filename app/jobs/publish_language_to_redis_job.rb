class PublishLanguageToRedisJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(calmapp_version_id, translation_language_id, redis_db_id)

    begin
      # c
      #tu = TranslationsUpload.find(translations_upload_id)
      #tu.write_yaml()
      #redis_db = RedisDatabase.find(redis_db_id)
      RedisDatabase.version_language_publish_from_ids(calmapp_version_id, translation_language_id, redis_db_id)  
    rescue => exception
      ExceptionNotifier.notify_exception(exception,
      {:data=> {:class=> RedisDatabase, :calmapp_version_id => calmapp_version_id.to_s, 
        :translation_language_id => translation_language_id.to_s, :redis_db_id => redis_db_id.to_s, 
        :method=> "version_language_publish_from_ids" }})
        #:data => {:worker => worker.to_s, :queue => queue, :payload => payload})
        #:data => { :queue => queue, :payload => payload})
        info "Exception in version_language_publish() " +exception.message
        exception_raised
        raise
    end
    # Do something later
  end
end
