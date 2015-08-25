#Tasks that are Executed in Background (via delayed_job gem)
###AddEnKeysForNewLanguageJob
When a new translation language is added to a version, all the keys already in English must be added as incomplete translations to the new language
>> Works from CalmappVersionsTranslationLanguage by calling the add_all_dot_keys_from_en_for_new_translation_language
###AddOtherLanguageRecordsToVersionJob
When  a new translation is addded to English then all other languaes must get an incomplete translation for later completion
>>Calls add_other_language_records_to_version
###CavstlDestroyDependentsJob
>>Called before destroy in CavstlDestroyDependentsJob
>>> *Deprecated*
###PublishLanguageToRedisJob
>>When a translation language is ready to be used it can be pulbished to a redis database for use or checking (depending on the database chosen)
>>> *Only completed records are written*
###PublishVersionToRedisJob
>>When a version is ready to be used (ie all needed translations are complete) it can be pulbished to a redis database for use or checking (depending on the database chosen)
>>> *Only completed records are written*
###TranslationsUploadWriteYamlJob
>>When a yaml file is uploaded then this job writes translations from this file to the database.
>>> This is done according to the users instrucitons for overwriting (or not)
