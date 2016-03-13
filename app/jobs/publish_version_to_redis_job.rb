class PublishVersionToRedisJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(redis_database_id)
    begin

      rdb = RedisDatabase.find(redis_database_id)
      rdb.version_publish
      puts "Successfully competed " + self.class.name + " redis_id " + redis_database_id.to_s
    rescue => exception
      ExceptionNotifier.notify_exception(exception,
      :data=> (rdb ? {:class=> RedisDatabase, :calmapp_version_id => rdb.calmapp_version_id.to_s, 
         :method=> "version_publish"  } : {:context => "PublishVersionToRedisJob param", :id => redis_database_id.to_s}))
        exception_raised(("Exception in version_language_publish() " + exception.message), exception.backtrace)
        raise 
    end
    # Do something later
  end
end
