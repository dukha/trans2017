##Callbacks in Translator

  ###* __Calling Class:__ *CalmappVersionsTranslationLanguage*
   * __Event:__ create
      * __Jobs or Methods:__
         * <span style="color:blue;">_:base_locale_translations_for_new_translation_languages_</span>
           * __Description__
           >> Uploads new base translation file when a new language is added to a version
           * __Delay?__
           >> No
         * <span style="color:blue;">_:add_this_to_sysadmin_users_</span>
          * __Description__
          >> Adds a the new version_translation_language to all users with sysadmin privelege. Others must be added manually.
          * __Delay?__
          >> No
    * __Event__ commit on create
       * <span style="color:green;">_AddEnKeysForNewLanguageJob_</span>
           * __Description__
           >> Loads the base translations for the new language
           * __Delay?__
           >> Dev: now, Prod: 2min
       * <span style="color:green;">_CheckAllEnKeysAvailableInNewLangJob_</span>
           * __Description__
           >> Checks that all keys in English also exist for new language (with default translastion (either nil, [], {} or "false"))
           * __Delay?__
           >> Dev: 2min, Prod:5min

  ###* __Calling Class:__ *Translation*
   * __Event:__ after_commit
      * __Jobs or Methods:__ 
         * <span style="color:green;">_AddOtherLanguageRecordsToVersionJob_</span>
           * __Description__
           >> Uploads new base translation file when a new language is added to a version
           * __Delay?__
           >> Dev: 2min Prod: 5min
         
     * __Event:__ before validation
       * __Jobs or Methods:__
         * <span style="color:blue;">_:do_before_validation_</span>
           * __Description__
           >> Massages data
           * __Delay?__
           >> No
     * __Event:__ after destroy
       * __Jobs or Methods:__
         * <span style="color:blue;">_:delete_similar_dot_keys_not_english_</span>
           * __Description__
           >> When English translatons are deleted then each english key that is deleted must be removed from all other translations
           * __Delay?__
           >> No   

  ###* __Calling Class:__ CalmAppVersion
    * __Event:__ before create
      * __Jobs or Methods:__
         * <span style="color:blue;">_do_on_create() / :add_english_</span>
           * __Description__
           >> Adds english language to the version before any other language is added.
           * __Delay?__
           >> No

  ###* __Calling Class:__ RedisDatabase
    * __Event:__ after create
      * __Jobs or Methods:__
         * <span style="color:blue;">_:flush_db_</span>
           * __Description__
           >> Makes sure the db has no data in it
           * __Delay?__
           >> no
    * __Event:__ after commit on create and update
      * __Jobs or Methods:__
         * <span style="color:blue;">_do_after_commit / calmapp_version.update_columns()_</span>
           * __Description__ 
           >> Keeps translator publishing copacetic
           * __Delay?__
           >> No            
    * __Event:__ after destroy
      * __Jobs or Methods:__
         * <span style="color:blue;">_do_after_destroy / calmapp_version.update_columns()_</span>
           * __Description__ 
           >> Keeps translator publishing copacetic
           * __Delay?__
           >>  No   

  ###* __Calling Class:__ RedisInstance
    * __Event:__ after_initialize
      * __Jobs or Methods:__
         * <span style="color:green;">_default_values()_</span>
           * __Description__
           >> Sets default port etc
           * __Delay?__
           >> No
  ###* __Calling Class:__ TranslationsUpload
    * __Event:__ after_create
      * __Jobs or Methods:__ do_after_create
         * <span style="color:blue;">_dot_after_create / TranslationsUploadWriteYamlJob_</span>
           * __Description__
           >> Writes the uploaded yaml to the relational database
           * __Delay?__
           >> later     
    * __Event:__ before_destroy
      * __Jobs or Methods:
         * <span style="color:green;">___ do_before_destroy_</span>
           * __Description__
           >> Removes upload
           * __Delay?__
           >> No

  ###* __Calling Class:__ Contact
    * __Event:__ after_create
      * __Jobs or Methods:__
         * <span style="color:blue;">_:mail_to_admin_</span>
           * __Description__
           >> Lets admin know that there is another contact to reply to
           * __Delay?__
           >> deliver_later
  ###* __Calling Class:__ UserProfile
    * __Event:__ after_commit on_create
      * __Jobs or Methods:__
         * <span style="color:blue;">_:add_cavs_tls_</span>
           * __Description__
           >> Adds all the good priveleges to sysadmin
           * __Delay?__
           >> No

  ###* __Calling Class:__ User
    * __Event:__ before_validation
      * __Jobs or Methods:__
         * <span style="color:blue;">_:check_username_</span>
           * __Description__
           >> Checks no white space in username
           * __Delay?__
           >> No
    * __Event:__ after_invitation_accepted      
         * <span style="color:green;">_notify_admin_</span>
           * __Description__
           >> mails admin to let them know  that a user has accepted and needs a profile.
           * __Delay?__
           >> deliver_later




               