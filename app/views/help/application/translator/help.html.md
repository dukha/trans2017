##Translator Role Help
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
#####Introduction
A single translation consists of the following information

* An application version language
  - For example _Calm version 4 German_
* A code (called Dot Key Code in Translator because it is in a form separarated by dots)
    -  e.g. _activerecord.models.course.location_
  - It is the key to this translation in all languages
* The translation itself 

#####Just want to get started now?
* Read these 2 pages first 
  - [Role of English](<%=role_of_english_help_path%>)
  - [Substitutions](<%=translation_interpolations_help_path%>)
  - [Translation User Interface](<%=translator_ui_path%>) 
* Then Click 
  - [Translations](<%=translations_path%>)

#####Getting Started
Click [Getting Started](<%=getting_started_path%>)
#####Translators' User Interface
Click [Translations UI](<%translator_ui_path%>)
#####More Information about Translations
Click [Translation Types](translator_objects)
#####To Understand How the Translation Process Works
Click [Translation Process](translation_process)
#####To Understand Codes in the translations
Click [Role of English](<%=role_of_english_help_path%>)
#####To see what needs to be completed in this application
Click [Programmers' Todo List](<%=todo_path%>)
