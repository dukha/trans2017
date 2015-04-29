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
  
  def self.self_demo
    # demo creates redis db 0 on marks development machine and loads it with default en.yml
    # We will now load all the other yaml files for the en translation of this application (Translator)
    marks_redis_instance = RedisInstance.where { description =="Mark's Desktop Computer"}.first
    
     redis = RedisDatabase.where{redis_db_index == 0}.
            where{redis_instance_id == my{marks_redis_instance.id}}.
            joins{calmapp_version.calmapp_versions_translation_languages.translation_language}.
            where{calmapp_version.calmapp_versions_translation_languages.translation_language.iso_code == 'en'}.
            select{"calmapp_versions_translation_languages.id as cavtl_id, redis_db_index, redis_databases.id as id, redis_instance_id, redis_databases.calmapp_version_id as calmapp_version_id, release_status_id "}.
            first
    
    #RedisDatabase.where{redis_db_index == 0}.where{redis_instance_id == my{marks_redis_instance.id}}.joins{calmapp_version.calmapp_versions_translation_languages.translation_language}.where{calmapp_version.calmapp_versions_translation_languages.translation_language.iso_code == 'en'}.select{"calmapp_versions.calmapp_versions_translation_languages.id as cavtl.id"}
    upload_from_dir = 'config/locales'
    files_to_upload =[File.join(upload_from_dir, 'common.en.yml'), 
                      File.join(upload_from_dir, 'devise_invitable.en.yml'),
                      File.join(upload_from_dir, 'devise.en.yml'),
                      File.join(upload_from_dir, 'translator.en.yml')  ]
    count = 0
    files_to_upload.each{ |f|
      count += 1
      tu = TranslationsUpload.new(description: "self demo " +count.to_s, cavs_translation_language_id: redis.cavtl_id, yaml_upload: File.new(f) )
      tu.save!
      }
    #version = CalmappVersioon.find(redis.cav_id)
    redis.publish_version                    
  end
end