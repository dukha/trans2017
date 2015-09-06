#Getting Started with Translation
#What Translation Involves
> **Whenever an application is needed for an international group of users, everything that the user can see should be available in their own language, apart from data that is entered by another user in another language.**
> The headings on a page should be translatable.
> The labels for data items in a form should be translatable
> The column headings in a data list should be translatable. 
> Any Tab Headings should be translatable. 
> Any hints for the user should be translatable.
> Any data that doesn't change very much should be translatable. This data is often in a pick list, or dropdown list. 
> Search criteria should be translatable.
###How does an application use translation?
> Each translatable item is given a code by a programmer. 
>> The programmer also gives the English translation of the item.
>> There is a special file that matches the code with the English translation. 
>>> All other translations use the same code to match to the translation.
>> Each language is identified by a special code known as an *iso code*. For example 
>>> English is en, 
>>> Dutch is nl, 
>>> Chinese is zh. 
>> Sometimes there can be variations in a language depending on where it is spoken. 
>>> These can be taken care of by a regional code added to the language iso code. 
>>> For example the french spoken in France can be given the code fr_FR to distinguish it from French spoken in Canada which is fr_CA.  
        
