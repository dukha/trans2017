
puts "Seeding using " + Rails.env
#require 'dotenv'
#Dotenv::Railtie.load

log=Logger.new(STDOUT)
DelayedJob.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('delayed_jobs')
Contact.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('contacts')
UserProfile.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('user_profiles')
CavsTlTranslator.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('cavs_tl_translators')
CavsTlDeveloper.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('cavs_tl_developers')
CavsTlAdministrator.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('cavs_tl_administrators')

User.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('users')
Profile.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('profiles')

RedisDatabase.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('redis_databases')
RedisInstance.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('redis_instances')
CalmappVersionsTranslationLanguage.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('calmapp_versions_translation_languages')
CalmappVersion.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('calmapp_versions')
Calmapp.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('calmapps')

Language.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('languages')
TranslationLanguage.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('translation_languages')
TranslationHint.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('translation_hints')
TranslationsUpload.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('translations_uploads')
Whiteboard.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('whiteboards')
ReleaseStatus.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('release_statuses')
WhiteboardType.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('whiteboard_types')

#Profile.delete_all    
#ActiveRecord::Base.connection.reset_pk_sequence!('Profile')

puts '*************'
puts Rails.env
puts '***********'
SpecialPartialDotKey.delete_all
DotKeyCodeTranslationEditor.delete_all
#TranslationEditorParam.delete_all
Translation.delete_all

#Remove old upload files
upload_path = File.join(Rails.root, TranslationsUpload.uploaded_to_folder, "uploads/translations_upload/yaml_upload/")
#dir = Dir.new(upload_path)
FileUtils.rm_rf(upload_path) if Dir.exist?(upload_path)

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


Whiteboard.create!(:whiteboard_type_id=> systemWBType.id, :info => 'WELCOME TO TRANSLATOR.')#:info=>"Translator application under development." )
Whiteboard.create!(:whiteboard_type_id=> userWBType.id, :info=> 'Edit to write message here.')#"We need translators for Russian.")
log.info("Whiteboards data inserted successfully.")

en = TranslationLanguage.seed

TranslationHint.seed

Profile.seed
log.info("profiles seeded")

SpecialPartialDotKey.seed  
DotKeyCodeTranslationEditor.seed

# These are languages for this application
Language.create!(:iso_code=> "en", :name=>"English") #, :parent_id=>translation_organisation.id)

User.seed
log.info("Users inserted")

puts "end of seeds"
