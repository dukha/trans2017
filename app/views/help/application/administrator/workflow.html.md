##Administrator Work Flow for creating New Applications and Versions in Vipassana Translator
####New Applications will only be created occasionally. Go to [New Applications](<%=new_calmapp_path%>) or go via [Applications](<%=calmapps_path%>)
>>While you are in the new application page, you can add the first version as well, if you like. Just click _Add New Version_

####A new version of an application can be created everytime there are going to be major changes to what needs translation. For example, if there are going to be a lot of deletions.
>>A new version numbering may or may not be inline with application versions.
>>Whenever a new version is created the base translations for the application framework are added automatically.
>>Whenever a new version is created, a new empty translation section is ready in the database. A new version starts from, more or less blank translations.
>>You will need to add the needed languages. Go to [Change Version Languages](<%=calmapp_versions_path%>)
>>>>When you do this the new base translations for the new languages will be automatically uploaded.
>>>>Also new blank translations will be added for any other English translations that already exist.
>>>>You can add any other translation files that the developers have provided the language already exists for the version

####A better alternative is to deep copy the old version(see [Deep Copy Help](<%=help_deepcopy_path%>)) rather than create a brand new version. 
>>In this way old translations, no longer needed can be deleted easily but needed translations will be kept. The old version can continue to run without a problem and the new translations can be added without interfering.


####Whether you copied or created, you will need to add user permissions for the users that will translate this version. 
>>Go via [Users](<%=users_path%>). 

####To publish a new version, you will need to have a Redis Instance and a Redis Database available
>> A redis instance can be used by more than 1 version and more than 1 application.
>>>> See  
>>>> Each redis instance can have many redis databases, usually 16 or 32
>> Every redis database can have only 1 version
>> However you can publish a version to many different redis databases e.g. A database for developers, a database for production. 
>> See[Redis Databases Help](%=redis_databases_help_path%>)
 
