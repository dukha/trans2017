#Callbacsks Used in Translator
##calmapp_versions_translation_language: 
* after_create :base_locale_translations_for_new_translation_languages
>>Adds the base translations for the language
*after_commit :after_commit_on_create, :on => :create
>> this calls add_all_dot_keys_from_en_for_new_translation_language()
* before_destroy :deep_destroy
  
##calmapp_version: 
* before_create :add_english
>>Adds the English language to the version if the user left it out. Englsh is required for all versions
>>Not done as delayed job as a short process.

##redis_instance 
* after_initialize :default values
>>Adds the default port and default maximum databases to the instance)

redis_database
* after_create :after_create_method

##translation
* before_validation :do_before_validation
> if en
>> add special_structure info to translation
All languages
>> do_incomplete Adds the incomplete data to translation if en record is a special structure
* before_save :translation_valid_json? 
* after_create :add_other_language_records_to_version, :if => Proc.new { |translation| translation.language.iso_code=='en'}
>>When a new English translation is added, it adds nil translations for all other existing languages.
* after_destroy :delete_similar_dot_keys_not_english, :if => Proc.new { |translation| translation.language.iso_code=='en'}
>>When English translation is deleted then delete all other translations for same dot_key in that version

##translations_upload  
* after_commit :do_after_commit, :on => :create
>>Writes uploaded yaml file to db
  
##contact
* after_create :mail_to_admins
>>todo

##user_profile
* after_commit :add_cavs_tls, :on => :create

##user
* before_validation :check_username
* after_invitation_accepted :notify_admin