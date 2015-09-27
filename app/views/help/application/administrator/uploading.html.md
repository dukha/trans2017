#Uploading Files
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
* A developer(or administrator) needs to upload translation files to get the translation process started. Thes files are generally in English.
* Remember that 1 English base file is autmatically uploaded whenever a version is created.
>>* Its translations are added to the translations for that version
* Some of the programming libraries that the developers have used may also provide translation files.
>>* The developer should upload these files as well.
* Some libraries may even provide translation files for some other languages. 
>>* These translation files can be uploaded as well.
>>>>* When uploading multiple translation files in different languages from a library, make sure that the English is loaded first, otherwise the other languages will not be written.
* The files to upload must be in a valid yaml format. If not you will get an error.
* The translations provided by libraries may be changed in Vipassana Translator(VT) if they are not good enough. 
* When translations from other languages are uploaded they will not be written if the key for the translation is not already in the English.
* When you upload(in menu/Translation Administration/[Translation Uploads](<%=calmapp_versions_translation_languages_path%> and clicking *Change Uploads*)) then you have a choice of how VT handles duplicate keys.
>>>>* *Overwrite existing translations*
>>>>* *Save Only New Translations*
>>>>* *Cancel the upload: rollback all translations from that file*
* Usually *Save only New* is enough. The library maker will ensure that there is a part of the code for each translation that is unique for that libarary. 
* You would use *Overwrite* if you were a developer who was uploading a file a second or third time and had corrected/improved some of the translations.

