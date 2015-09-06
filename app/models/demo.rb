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
    
    #TranslationLanguage.demo
    
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
  
  def self.translation_demo
    #regv = CalmappVersion.joins{:calmapp}.joins(:redis_databases).where{calmapp.name == 'calm_registrar'}.first
    #regv = CalmappVersion.joins{:calmapp}.joins(:redis_databases).where{calmapp.name == 'calm_registrar'}.where{redis_databases.release_status_id == 1}.select("redis_databases.id").first
    regv_query = CalmappVersion.joins{:calmapp}.joins(:redis_databases => :release_status).where{calmapp.name == 'calm_registrar'}.where{redis_databases.release_statuses.status == "Development"}.select("calmapp_versions.id as cav_id, redis_databases.id as rdb_id").first
    regv = CalmappVersion.find(regv_query.cav_id)
    rdb = RedisDatabase.find(regv_query.rdb_id)
    cavtl_en = CalmappVersionsTranslationLanguage.where{calmapp_version_id == my{ regv_query.cav_id}}.where{translation_language_id == my{TranslationLanguage.TL_EN.id}}.first
    reg_upload_dir = '/home/mark/Workspace/registration/config/locales/'
    cavtl_en.translations_uploads << TranslationsUpload.new( :yaml_upload => File.new(File.join(reg_upload_dir, "calm.en.yml")), :description => "test calm")
    regv.translation_languages << TranslationLanguage.all - regv.translation_languages #[TranslationLanguage.TL_EN]
    
  end
  def self.integ_big_demo
    RedisDatabase.integ_big_demo
  end
end