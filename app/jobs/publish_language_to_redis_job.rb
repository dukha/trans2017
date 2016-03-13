class PublishLanguageToRedisJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(calmapp_version_id, translation_language_id, redis_db_id)

    begin
      RedisDatabase.version_language_publish_from_ids(calmapp_version_id, translation_language_id, redis_db_id)
      puts "Successfully competed " + self.class.name + " version_id = " + calmapp_version_id.to_s + " redis_db_id " + redis_db_id.to_s  
    rescue => exception
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> RedisDatabase, :calmapp_version_id => calmapp_version_id.to_s, 
        :translation_language_id => translation_language_id.to_s, :redis_db_id => redis_db_id.to_s, 
        :method=> "version_language_publish_from_ids" })
 
        exception_raised(("Exception in version_language_publish() " + exception.message),exception.backtrace)
        raise
    end
    # Do something later
  end
end
