##Introduction to Publishing Translations
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
* Publishing is done to an in memory database called Redis. This is very fast and perfect for serving translations.
* Redis only knows the key(which includes the language) and the translation
>>For example one Dutch translation is
>>>*nl.activerecord.attributes.course.start_date* __Begin datum__
* For more information about Redis go to [Redis Databases](<%=redis_databases_help_path%>). 
* If translations are to be published then decide whether the whole version needs to be published or just a few languages are now ready to publish.
>>Accordingly you can publish a Whole version by going to menu / Publishing / [Publish Application Version](<%=redis_databases_path%>).
>>Or publish a language by going to menu / Publishing / [Publish a Language](<%=calmapp_versions_translation_languages_path%>).  
* Vipassana Translator will only publish complete translations. If a translation is empty, just "" then it will not be published.
>> If a plural translation does not have all plural options complete then it will not be published.
>>>For example(Russian) in
>>>>*ru.datetime.distance_in_words.about_x_months* is 
>>>>>>*few*: __около %{count} месяцев__<br>
>>>>>>*many*: __около %{count} месяцев__<br>
>>>>>>*one*: <br>
>>>>>>*other*: __около %{count} месяца__<br>

>>>*one* has not been translated so this translation will not be published.

* Publishing can be done over and over again with no problem.
* When you publish a language then nothiong will be deleted. Only existing translations will be overwritten and new ones created.
* When you publish an __application version__ then the every translation __is deleted__ from redis and then re-published from the database.

###Administrator Publishing
- An administraor can publish either all translations in all languages for a version OR
- All translations for 1 language in a version
- For details on this see [Publishing by an Administrator](<%=administrator_publishing_help_path%>)
- To see how to set up a database for Translator Publishing see [Setting Up Translator Publishing](<%=admin_applications_versions_languages_path  + "#publishing-bookmark"%>)
###Translator Publishing
- Translators can publish translations to a test redis database so that they can see their work.
    - For details of how an administrator can see this up see [Setting Up Translator Publishing](<%=admin_applications_versions_languages_path  + "#publishing-bookmark"%>)
    -For a translator to see how to do this see [Translator Publishing](<%=translator_publishing_help_path%>)   