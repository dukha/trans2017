##Redis Installation
<%=raw(render :partial => $APPLICATION_HELP_VIEW_DIR + "shared/horizontal_menu") %>
 
 * To install Redis on (K)Ubuntu for Translator
> * Install Redis server as normal (from _Muon_ or _apt-get install_).
> * The installation will include redis-cli
> * Start redis-cli 
>> * $ redis-cli
     <div style="color:light-gray;" select db 0 </div>   
>> *     redis $ select 0
>> *     redis $ get xxx
     (=> nil)
>> *     redis $ set xxx abc90
>> *     redis $ get xxx
     (=> abc90)
> * You need to set a password
>> * redis-server and redis-cli are both installed in /usr/bin
>> * redis.conf is in /etc/redis
>> * edit redis.conf and uncomment requirepass. Put in your own password. When you go to production, you will have to give a password of al least 100 chars to prevent brute force attacks.
>> * in production you will need to comment out bind 127.0.0.1
>> * and add bind 0.0.0.0
>> * This will allow connections from anywhere whereas 127.0.0.1 will only allow connections from developers machine.
>> * Setup **appendonly saving** according to the doumentation in redis.conf
>>> * appendonly yes
>>> * appendfsync everysec
>> * For instllation to work you will need to active asyncronous processing in Translator. Do this by starting the rake task jobs:work or the daemon.(See redis gem documention.) The normal write data tasks include starting the jobs:work task. Production requires the daemon.
