##Administration of Applications, Versions and Languages
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
###Applications
> An application is a piece of software e.g Vipassana Translator, Calm
> In the Translation Admin menu, you can add a new applicaton by clicking on [Applications](<%=calmapps_path%>), then [Add Applicaton](<%=new_calmapp_version_path%>)</i>.
>> Once you have given the name, you can add the first version stright away.

###Versions
>Versions usually have a number like 3 or 3.4 or 3.1.4 but sometimes a name, like 'Long Horn'(an infamous version name from Microsoft).
>> When adding an application, click [Add Application Version](<%=new_calmapp_version_path%>) . Alteratively you can start from [Application Versions](<%=calmapp_versions_path%>). Give the name or number of the version
>> When you save you will always have english as the base language. It is added automatically, together with about 150 translations that are needed by every application.
>> Save the application and versions. This will also add some English translations. New English translations are usually added by developers.


###Languages
>  To add the languages needed for translation, click on [Change Version Languages](<%=calmapp_versions_path%>). Choose the version that you have just added.
>> and click <i>Edit(including Languages)</i> 
>>> Move the languages required to the right by using the right arrows or double clicking
>>> <i>Update Application Version</i>.<br>
>>> Translations for the English basic translations will be added at this time.
> You must always have an English translation before another translation can be added.

### <a name = 'publishing-bookmark'></a>Setting up Translator for Publishing (of Translations). 

> This is a special function that administrators can set up for each version.
> Each version can have 1 nominated Redis database that will be the translators test database. 
> One redis database can be set aside for test translations so that a transslator can review his/her own translations
> To do this go to __menu__ / __Translation Admin__ / __Application Versions__
> From here select your version by clicking on __Changes Redis Databases__
>> This page lists all the redis databases for that version.
>> Before clicking a Redis dababase to be the translators test, you have to ensure that a test version of the application version is running on the same server(otherwise the test version will not work for the translator).
>>> You can add another Redis if you want. or choose one of the existing redis databases.
>>> Click the checkbox under __Used by Publishing Translators__. 
>>>> Note that only 1 of these databases can be clicked for each Version

 
