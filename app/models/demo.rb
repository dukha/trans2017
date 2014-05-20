class Demo
  
  def self.demo
    reg = Calmapp.create!( :name=>"calm_registrar")
    trans = Calmapp.create!(:name=>"calm_translator")
    log.info("Calm applications inserted")


    reg4 = CalmappVersion.create!(:calmapp_id => reg.id, :version => 4)
    trans1=CalmappVersion.create!(:calmapp_id => trans.id, :version => 1)
    log.info("Calm application version inserted")

    ri_local = RedisInstance.create!(:host=>"192.168.0.1", :password => '123456', :port => '6379', :max_databases=>16, :description=> "Developer's Desktop Computer(only)")
    ri_integration = RedisInstance.create!(:host=>"31.222.138.180", :password => '123456', :port => '6379', :max_databases=>32, :description=>'Integration Server')
    log.info("Redis instances inserted")

    TranslationLanguage.demo
    
    TranslationsUpload.demo
  end
end