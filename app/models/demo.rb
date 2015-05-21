class Demo
  def self.mini_demo
    log.info"Starting demo stuff"
   
    log.info "Users added"
    Calmapp.demo
    log.info("Calm applications reg and trans inserted")

    CalmappVersion.demo
    log.info("Calm application versions inserted interted for reg(4) and trans(1)")
    
    RedisInstance.demo
    log.info("Redis instances inserted instances on integration and marks pc")
    
    RedisDatabase.demo
    log.info("Redis dbs inserted")
  end
  
  def self.demo
    self.mini_demo

    #marks_redis = RedisInstance.create!(:host=>"118.211.147.135", :password => '123456', :port => '6379', :max_databases=>16, :description=> "Mark's Desktop Computer")
    
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
  
  def self.marks_big_demo
    # demo creates redis db 0 on marks development machine and loads it with default en.yml
    # We will now load all the other yaml files for the en translation of this application (Translator)
    RedisDatabase.marks_big_demo                  
  end
  
  def self.integ_big_demo
    RedisDatabase.integ_big_demo
  end
end