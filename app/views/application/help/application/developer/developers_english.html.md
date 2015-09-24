##English
<%=raw(render :partial =>"application/help/application/shared/horizontal_menu") %>
 > * English(code '_en_') has a special role in the Translator app. It is the base language.
 >> * Developers use this language to create the initial translations from which everyone else works.
 >> Translations with code '_en_' cannot be edited or deleted other than by developers(or system administrators).
 >> As an developer, you need to be very careful about the quality of English as it will be used as the basis for all translations.
 >>> There should be no typos, clear syntax and short sentences. __Translations are only as good as the English original.__ Garbage in, garbage out.
 > * If you wish to have an English translation different from English(_en_) then an administrator can make a variant of English by using the deep copy method. 
 >> A variant would normally be named by adding a country code to _en_. For example a variant with American spellings would be named _en-US_.
 >> Using a country code is not required. You could call it by the name of your centre eg '_en-DHAMMA-RASMI_'. 
 >> If you do something like this remember than after that you will have to maintain it with new translations. 
 >>> ** Having individual translations like en-DHAMMA-RASMI is NOT recommended**.
