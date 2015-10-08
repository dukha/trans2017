##Deep Copy 
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>

####Where?
You can deep copy a version-language or a complete version.
####Why Version-Language

* You would want to deep copy a version-language in the case where you had a complete translation and you also wanted a regional variant, where mostly the translations would be the same, but with some diferences.
> * Examples might be
>> * You have English(en) but want an American version of English. Copy the en version to en-US
>> * You have a standard Dutch version(nl) but you want a Flemish version as well. Copy the nl version to nl-BE

####Why Copy a complete Version
 * You have finsihed version 1 which is in production. Developers start version 2 but there will be big changes. So copy Version 1 to a new Version 2.
