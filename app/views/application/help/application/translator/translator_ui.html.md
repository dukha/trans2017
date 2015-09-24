##Translator User Interface
<%=raw(render :partial =>"application/help/application/shared/horizontal_menu") %>
### Selection Criteria 
<%=image_tag('help_criteria.png')%>
* Translation is always done on the translations index screen. When you click on the [Translations](<%=translations_path%>) menu you see the criteria choices below.
* Note the 2 warning messages at the top, asking you so set the Applicaion Version that you want and the Language. (You can set other things as well, such as a (part of) the key or a (part of) the translation.
* Note also the small plus(+) sign in the box on the top right. This allows you to expand the translation area for easy translation.
* You can see that under  the hide criteria button (for more screen space) there is a row of choices
  >> __All Translations__   means that you will select all the translations for your application version and language.
  >> __Untranslated__ means that you will see only your translations that have not been translated.
  >> __Newer English Translations__ means that you will see only your translations where the English has been updated. You need to check these against your translations. May be you need to change before publication. Always do this before publication.
  >> __Untranslated and Newer English Translations__ means a combination of the above 2 (ie untranlated and newer English)
******
###First page of Result of Selecting all Czech criteria for Calm
<%=image_tag('help_czech_all.png')%>
* Note that the the selection cirteria are automatically hidden
* These translations can be edited by clicking on the blue links in the Czech translation column
* Note that there are 6 pages. These can be navigated by clicking the next link (or one of the page numbers) just under the Show Criteria button.
******
###Editing a Translation(Japanese)
<%=image_tag('help_editing.png')%>
* By clicking on the blue text an editing area will appear. Change the text and click Save or Cancel.
  >> The editing area will disappear and if you clicked Save a success or error message will appear.
  >> The message may not come immediately but it is ok to go straight to your next edit.
******
###Editing a plural(Dutch)
<%=image_tag('help_editing_plural.png')%>

* For plurals there are 1 or more slots to edit for different languages. These slots have references to count like *one, other* or *one, few, other* or *other* depending on the language.
>> Make sure that you add something for every slot in your language, even if you think that it is not necessary. The translation cannot be published unless all plural types have a translation.
******
####If just starting with translations, but sure to read
  - [Substitutions](<%=translation_interpolations_help_path%>)
  - [Role of English](<%=role_of_english_help_path%>)

