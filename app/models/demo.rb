class Demo
  
  def self.demo
    reg = Calmapp.create!( :name=>"calm_registrar")
    trans = Calmapp.create!(:name=>"calm_translator")
    log.info("Calm applications inserted")


    reg4 = CalmappVersion.create!(:calmapp_id => reg.id, :version => 4)
    trans1=CalmappVersion.create!(:calmapp_id => trans.id, :version => 1)
    log.info("Calm application version inserted")

    #marks_redis = RedisInstance.create!(:host=>"118.211.147.135", :password => '123456', :port => '6379', :max_databases=>16, :description=> "Mark's Desktop Computer")
    marks_redis = RedisInstance.create!(:host=>"45-highfield.internode.on.net", :password => '123456', :port => '6379', :max_databases=>16, :description=> "Mark's Desktop Computer")
    ri_integration = RedisInstance.create!(:host=>"31.222.138.180", :password => '123456', :port => '6379', :max_databases=>32, :description=>'Integration Server')
    log.info("Redis instances inserted")

    TranslationLanguage.demo
    
    TranslationsUpload.demo

    reg4.calmapp_versions_redis_database << CalmappVersionsRedisDatabase.new(
               :release_status => ReleaseStatus.where{status == "Development"}.first, 
               :redis_database => RedisDatabase.create!(
                                   :redis_instance => marks_redis, 
                                   :redis_db_index => marks_redis.unused_redis_database_indexes[0]
                                   )
               )
     Profile.demo           

  end
end