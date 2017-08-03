##Translator Publishing
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
####Introduction
You may wish to publish your translations to view the results of your work.
Provided an administrator has set it up for you, you may do this. 
First make sure that you are logged in as a translator.
<%if has_role?(:users_translatorpublishing)%>
>>Go to __menu__ / __Translations__/ [What Redis Databases Can I Publish To?](<%=tlink_to("translators_redis", translator_publishing_path(current_user.id), 
            {:category=>:menu,
            :remote=> true,
            :method=> "get"
            }) %>)
<%else%>
>>>Go to __menu__ / __Translations__ / __What Redis Databases Can I Publish To?__ when you recieve premission 
<%end%>
<<%has_role?  :calmapp_versions_translation_languages_translatorpublish do%>   
>>>If you have permission as above then go to __menu__ / __Publishing__ / [<%=I18n.t($M + "translator_publish_language")%>](<%=calmapp_versions_translation_languages_path%>)        
<%end%>
__As of Version 1.5, a translator may publish to a production database, provided an administrator has set the database up to be published to.__

If you are an administrator then you can also do the same publishing by going to __menu__ / __Translation Admin__ / __Versions and Languages__ and Clicking on the Translator Publish button for a version. 
####If just starting with translations, be sure to read
  - [Prerequisites](<%=prerequisites_path%>)
  - [Substitutions](<%=translation_interpolations_help_path%>)
  - [Role of English](<%=role_of_english_help_path%>)