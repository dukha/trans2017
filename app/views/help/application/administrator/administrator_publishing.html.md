##Administrator Publishing
###Introduction
- Publishing is done to copy completed translations from the relational database where they are stored to the in-memory database, Redis.
- Each application version can have its translations published to multiple redis databases on multiple servers.
    - However the servers that are used to publish to must have a Domain Name so that they can be identified (Unless the publishing is local)
- To be used by an application the redis database that the application uses to translate must be on the same server as the application. 
    - This is not a technical limit is such, rather it is to make sure there is no delay in the application receiving the translations. 
- There are 2 types of publishing that an administrator can do(provided that admin has the correct permissions)
    - __Publishing a language:__ ie all the completed translation for a version in a particular language
    - __Publishing a version:__ This would publish all completed translations in all languages for a version
    - There is a third type of publication: __publishing of a language by a translator__ to a test database to review the translator's work.

###Publishing a Version
- Go to menu / __Publishing__ / [Publish Application Version](<%=redis_databases_path%>) . 
    - Click the __Publish to Redis__ button that matches the version and redis database that you wish to publish.
        
###Publishing a Language
- Go to menu / __Publishing__ / [Publish a Language](<%=calmapp_versions_translation_languages_path%>)      