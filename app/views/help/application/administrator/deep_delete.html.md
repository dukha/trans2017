##Deep Delete
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>

####What?
* Deep Delete means that you delete everything that depends on What you are deleting.
> * If you Deep Delete a version-language then you will delete all translations for that version
> * If you Deep Delete a version then all translations in all languages will be deleted for that version.

####Where?
* You can deep delete Version-languages or whole versions

#### Be Very, Very Careful.
* Once you deep delete than hundreds, possibly thousands of translation will be gone forever.

####Why?
* You no longer wish to support a language
* A version is superceded by a new version. The old version is no longer in use.

####Another Tricky Delete
* If you delete an English translation then all other translations of that Enlgish are also deleted
> * Be very careful about this also
> * See also [Developers English](<%developers_english_path%>)