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
 
