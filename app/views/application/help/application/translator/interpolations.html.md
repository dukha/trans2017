##Substitutions for Computer Codes in Translations
Sometimes translations need extra information provided at the last minute by the computer.

In the translation this is indicated by a substituion code in the English translation. 
> For example "_You are about to delete %{count} courses. Are you sure that you want to do this?_"
> %{count} is a special code. 
> Computer codes must be copied exactly to your translation. Computer codes always start with '_%{_' and end with '_}_'.
> The computer will substitute a number, for example 5 just before the user sees it.
> So the user would see the English translation of the above as "_You are about to delete 5 courses. Are you sure that you want to do this?_".
> The same translation in Dutch would be
> _U bent klaar om %{count} te verwijderen. Weet u zeker dat u wilt dit doen?_ 

It is important to make sure that you copy the codes exactly (Copy and Paste from English is better.) 

* Do not add any codes: this will cause an error.
* Please ensure that all the substituion codes from English are in your translation.
* Do not change the spelling of any codes. This will cause an error.
* Make sure all your substitions are surrounded by "%{" and "}" (no extra spaces)
  -  English %{count}
  - correct in translation  %{count}
  - __Incorrect in translation *{count}*__
  - __Incorrect in translation *%{ count}*__
  - __Incorrect in translation *%{Count}*__