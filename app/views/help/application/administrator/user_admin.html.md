##User Administration
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
####Inviting Users
>Generally users are invited by an administrator to become a user of Vipassana Translator(VT).
>You can inivte a new user by going to menu/User Admin/[New User Invitation](<%=new_user_invitation_path%>)
>Warn the user in advance that their invitation may end up in spam and that they should check their spam folder for mail from vipassana_translator.
>The user will receive a link with a token to enable them to fill out their own password and other data that is required.
>>NB the requirements for a valid password are 8 chars, at least 1 number and 1 special char like # @ ! etc
>>After the user has responded and filled in their data, you(the administrator) will receive a mail. (Check your spam!). You can then go to the application and give the user corect permissions to do their job.
>>Be sure to indicate a role for the user

>> * Developer
>> * Translator
>> * Application Administrator
>> * Sysadministrator

>>>With the first 3 you will also need to indicate which version languages they can work on 
>>Once you have done this the user will receive another mail telling them their account is read 
>>>The user is now ready to translate/develop/administer

####Setting Users Password
>Generally the administrator does not need to do this. A user can go menu/ User Preferences/*Change password or Email*
  
