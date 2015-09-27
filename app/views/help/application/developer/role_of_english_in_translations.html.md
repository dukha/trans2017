##Special Role of English
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
 > * English(code '_en_') has a special role in the Translator app. It is the base language.
 >> * Developers use this language to create the initial translations from which everyone else works.
 >> Translations with code '_en_' cannot be edited or deleted other than by developers(or system administrators).
See [More on English](<%=developers_english_path%>) for more information.
####If just starting with translations, be sure to read
  - [Substitutions](<%=translation_interpolations_help_path%>)
  - [Translation User Interface](<%=translator_ui_path%>)  
  
