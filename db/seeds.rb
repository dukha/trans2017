log=Logger.new(STDOUT)
UserProfile.delete_all
CavsTlTranslator.delete_all
CalmappDeveloper.delete_all
User.delete_all
Profile.delete_all

RedisDatabase.delete_all
RedisInstance.delete_all
CalmappVersionsTranslationLanguage.delete_all
CalmappVersion.delete_all
Calmapp.delete_all

Language.delete_all
TranslationLanguage.delete_all
TranslationHint.delete_all
Whiteboard.delete_all
ReleaseStatus.delete_all
WhiteboardType.delete_all

Profile.delete_all    

SpecialPartialDotKey.delete_all
DotKeyCodeTranslationEditor.delete_all
TranslationEditorParam.delete_all

systemWBType = WhiteboardType.create(:name_english=>"system", :translation_code=>"system")
regionalWBType =WhiteboardType.create(:name_english=>"regional admin", :translation_code=>"regionaladmin")
localWBType = WhiteboardType.create(:name_english=>"local admin", :translation_code=>"localadmin")
userWBType = WhiteboardType.create(:name_english=>"user", :translation_code=>"user")
log.info("Whiteboard Type data inserted successfully.")


vs_dev = ReleaseStatus.create!(:status => "Development")
vs_test = ReleaseStatus.create!(:status => "Test")
vs_integration = ReleaseStatus.create!(:status => "Integration")
ReleaseStatus.create!(:status => "Production")
log.info("Release Status data inserted successfully.")


Whiteboard.create!(:whiteboard_type_id=> systemWBType.id, :info=>"Translator application under development." )
Whiteboard.create!(:whiteboard_type_id=> userWBType.id, :info=>"We need translators for Russian.")
log.info("Whiteboards data inserted successfully.")
#User.create!(  :email=> 'translator@calm.org', :password=>'123456', :confirm_password=>'123456', :actual_name=> 'joe smith', :username => "joe",:current_permission_id=>1)

#en = Language.create!(:iso_code=> "en", :name=>"English")
#nl = Language.create!(:iso_code=> "nl", :name=>"Nederlands")
#log.info("Languages inserted")




# delete or change below usernameonce login is added
en = TranslationLanguage.seed#.create!(:iso_code=> "en", :name=>"English")

TranslationHint.seed

#red_reg4_loc_dev = RedisDatabase.create!(:calmapp_version_id => reg4.id, :redis_instance_id => ri_local.id, :redis_db_index => 1, :release_status_id => vs_dev.id)
#red_reg4_loc_test = RedisDatabase.create!(:calmapp_version_id => reg4.id, :redis_instance_id => ri_local.id, :redis_db_index => 2, :release_status_id => vs_test.id)
#red_trans1_int_dev = RedisDatabase.create!(:calmapp_version_id => trans1.id, :redis_instance_id => ri_integration.id, :redis_db_index => 1, :release_status_id => vs_dev.id)
#red_trans1_int_test = RedisDatabase.create!(:calmapp_version_id => trans1.id, :redis_instance_id => ri_integration.id, :redis_db_index => 2, :release_status_id => vs_test.id)
#log.info("Redis databases inserted")


Profile.seed
log.info("profiles seeded")

User.seed


SpecialPartialDotKey.seed  
DotKeyCodeTranslationEditor.seed
   





# These are languages for this application
Language.create!(:iso_code=> "en", :name=>"English") #, :parent_id=>translation_organisation.id)



   

#User.create!( :username=>'translator', :email=> 'translator@calm.org', :password=>'123456', :confirm_password=>'123456')
#User.create!( :username=>'admin', :email=> 'admin@calm.org', :password=>'123456', :confirm_password=>'123456')
#User.create!( :username=>'developer', :email=> 'developer@calm.org', :password=>'123456', :confirm_password=>'123456')
log.info("Users inserted")
