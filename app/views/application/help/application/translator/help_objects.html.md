##Things That Need a Translation
In a computer program there are broadly 2 things that you have to be aware of:

* **Objects**
* **Properties**

**Objects** are often referred to as _models_ (for translation)

**Properties** are referred to as _attributes_ (for translation) 

Examples of objects are 

* Course
* Student
* Course Type

**Course** will have **properties** like

* Start Date
* End Date
* Conducting AT's
* Type of Course

In the above examples of Course, there needs to be a translation of Course(singular) and Courses(plural)
and the properties Start Date, End Date, Conducting AT's and Type of Course.

**Hints**
As well each property may require a hint to help the user. This hint will be given(in English) by the programmers for more difficult to understand properties.
> For example a hint for Type of Course might be "_Enter the type here such as: 10 day course, 3 day course_"
 
**Menus**
Most objects will have a menu. This is often translated separately

**Actions**
When an action is going to take place then often there will need to be a translated text

* Update
* Publish
* Delete

**Roles**
A role usually consists of a model and an action
A user can have a number of roles such as 

* translations_update, 
* application_create. 

If a user is not given a role then he/she can't perform the role.

**Lookups**
Sometimes data that does not change very much is stored in the database and needs translation also
For example Course Types are fixed
They are all course types but there needs to be translation for 

* 10 Day Course
* 20 Day Course
* 1 Day Course

These are called lookups

**Messages**
Messages are communications to the user. They are usually simple, such as

* Translations Successfully Published
* This value is already taken. Choose another

**Error**
Errors are a particular kind of message which may be longer and tell the user how he/she could recover if a correction is possible.

**Tabs**
Tabs are areas of the screen that can be clicked on to show an entirely different view, like in modern browsers.
Tab names must be translated
