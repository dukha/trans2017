##Redis Databases Help
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
> The translation system involves making an individual translation in each language for each phrase, word or sentence. These translations are written to a relational database, where they are store securely. 
> When a translation is ready then it is published to an in memory database called Redis. This is a very fast database suitable for quick translation to multiple application users.
> This form involves matching the version with release status to a Redis database so that the translation can be published to where it can be used by the application quickly and easily.
###Release Status
> You can match a different Redis database for each Application Version and Release Status.
> One way of ensuring that the published translation data can be published to developers is to make several different Release Statuses, on for each developer e.g. Development-Ryan, Development-Mark. A developer can then publish their latest translations to their own development application.
###Redis Instance
> A redis instance is Redis running on a server. So you must indentify the server before identifying the database (by index).
###Redis Database Index
> Each Redis Instance has a predetermined number of databases (default is 16, numbered 0 to 15). One Redis database can contain one Version/Release Status. Thus you cannot choose a Redis Database Index that does not exist, nor an index that is already in use.
> Further, if you change a database index once some translations are published then all the published translations will disappear for that application version. If the release status is production then you will probably make the application unusable. Note that in this situation, it can be corrected by republishing, however a live application would be without translation until this was done.
