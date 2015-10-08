##Redis Instances
* Redis is an in memory database, perfect for serving translations as access to data is extremely fast.
* A Redis Instance is a computer which has Redis running through a particular port.
* A redis instance needs a code to access each item of data (ie each translation)
* The computer with Redis on it must be working before you can make a redis instance for Vipassana Translator
* The redis instance should be the same computer which has the application that needs the translations.
> * if you have redis on a different computer then the translation will be too slow.
> * The redis instance does NOT have to be on the same computer as Vipassana Translator.
* The redis instance should be dedicated entirely to translations. (Otherwise it is too easy for translations to be overwritten by something else.)
> * If redis is running on the computer in question and in use for something else then try starting redis a second time through a different port.
>> * Read the redis help and config file to see how to do this.

####Redis Password
* Redis password for production should be at least 100 random characters.
> * If it is not this long it is too easy for hackers to mount a brute force attack and crack redis.(Because it is so fast!)
> * You need to know the redis password when you setup a redis instance in Vipassana Translator.

####Redis Config file
* If you are managing Vipassana Translator ou need to be aware of redis config files and how each instance is setup.
* If Vipassana Translator is on a separate server then the config should allow external connections.
> * This may not be enough: Your sysadmin on the redis computer may have closed the port on which it is setup. You need to check with the sysadmin to make sure that the port is open
> * you need to know the port when adding a new Redis instance to Vipassana Translator.
* The number of redis databases managed by the redis server is speciified in the config. Default is 16. Each application version that is running will need a redis database.
> * You need to know how many databases a redis server has configured when adding a Redis Instance.
> * In Vipassana Translator, each version has at least 1 entire redis database to publish to. (No other data)
* We recommend background persistance for redis. This is not strictly necessary as the translation data is easily published again from Vipassana Translaator, but it will ease recovery in the event of a crash.
> * Background persistence is setup in redis config
####Developers' Redis
* If a developer wants a published version of redis, but does not have a recognisable domain name to publish to then the developer can always make his/her redis a slave of a master(like an integration master).
> * Do this in redis config
 

