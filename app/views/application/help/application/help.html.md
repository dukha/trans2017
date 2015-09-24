##Translator Application Help
<%=raw(render :partial =>"application/help/application/shared/horizontal_menu") %>
###Introduction
> Translator is meant to help you translate a software application into your own language by accessing the programmers codes and the English translation. The English translation has been added by the programmers as well.

> Translator works with 2 databases. When a translator makes a translation then the translation is written to a traditional (relational)database. 

> When the translation is finished then it can be published to an in-memory database, called __Redis__. Normally publication is done by and administrator.

> A developer inserts translation_codes into the application and then provides a translation for each code. The developer can add translations directly to the (relational) database or add them to a file in yaml format which can then be uploaded to the daatabase.

> An adminstrator normally would create new applications in the database, new application versions and add translation languages. 
> An administrator also would do uploads of yaml files and publish completed translations

> As you can see Translator has 3 types of users

* [Translators](<%=translator_help_path%>)
* [Developers](<%=developer_help_path%>)
* [Administrators](<%=administrator_help_path%>)
> Click here for
>> - [Help Contents](<%=contents_path%>)
>> - [Home](<%=whiteboards_path%>) 

