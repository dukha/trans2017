###Process of Translation
<%=raw(render :partial =>$APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
* When coding an application a programmer will leave codes instead of text. Each code is an indication that there needs to be a translation performed.
* The programmer will give an English translation of the code. This will be used for English users.
* For users of other languages, a native speaker must add the translation ofr each language needed.

####What happens when a new code is made by the programmer?
The programmer will add the translation to the translastion database. This will also immediately add the code to all the other languages listed to be tranlated with no translation.
* **This means that the translator never adds a new translation.** He/she only updates a translation with no value (or a wrong value) in it.
* The translator can changed a translation, but cannot delete it.
* If a programmer deletes an English translation then all other translations with the same code are also deleted for all languages.

####How does a user see the results of translations?
* Results are not visible immediately in the target application.
* This is because the translations must be published to a special (very fast) database where the translations can be read. 
* It may be possible for a translator to publish their own translations to a test (or even live) database.
  * The database is called Redis
* Publishing depends on wheter the adminstrator gives a translator that permission.

####Plurals are Tricky. How do they work?
* Different languages have different ways of dealing with plurals
* Even English has different ways, depending on the word
  * 1 sheep
  * Many sheep
  * 1 course
  * Many Courses
* Thus if plurals are required, they have to be dealt with individually. This is mainly when translating models, or objects.
* All English plurals can be handled in 2 categories but many languages require different categories.
  * one
  * other
* Russian, for example, requires
  * one
  * few
  * many
  * other
* Japanese requires only
  * other
  
Thus in the case of plurals not all plurals in all languages will correspond to the English plurals. The translator application should take care of this and present you with the correct choices to translate.
####How does the user find the records that need translating or changing?
* When you open the translation screen [Translations](../translations) you will first have to select what you want to translate.
  * This means your application version and language
  * You can then select a big group of records 
    * Untranslated - The translation is blank.
    * Need updating - The English translation is newer than your translation
    * All - All translations in your language
  * Or you can choose a very small group of translations by searching for a particular translation(in your own language) or in English or by code.    
   
####How do the comparisons work in order to select just a few translations?
* The comparison operator "**is**" means "**is exactly equal to**"
  * e.g. translation **is** "is too long" would only find these words. It would not find " is to long" as there is an extra space at the begining.
* The comparison operator "**contains**" means "**is somewhere in the translation**"
  * e.g. translation **contains** "is too long" would find "Message is too long." and "Error is too long" but would **not** find "Error is to lng" (2 misspellings!)    



