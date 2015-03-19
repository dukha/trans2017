class Demo
  
  def self.demo
    log.info"Starting demo stuff"
    Calmapp.demo
    log.info("Calm applications inserted")

    CalmappVersion.demo
    
    log.info("Calm application version inserted")

    #marks_redis = RedisInstance.create!(:host=>"118.211.147.135", :password => '123456', :port => '6379', :max_databases=>16, :description=> "Mark's Desktop Computer")
    RedisInstance.demo
    log.info("Redis instances inserted")
    
    RedisDatabase.demo
    log.info("Redis dbs inserted")
    TranslationLanguage.demo
    
    TranslationsUpload.demo
=begin
    reg4.calmapp_versions_redis_database << CalmappVersionsRedisDatabase.new(
               :release_status => ReleaseStatus.where{status == "Development"}.first, 
               :redis_database => RedisDatabase.create!(
                                   :redis_instance => marks_redis, 
                                   :redis_db_index => marks_redis.unused_redis_database_indexes[0]
                                   )
               )
=end
     Profile.demo
                
     User.demo
  end
end