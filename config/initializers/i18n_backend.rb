#DEPLOY

# default Redis.new gives localhost, 6379, db as 0, no authorisation needed. Otherwise as below
# redis = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 15, :password => 'xxx')
#I18n.backend= I18n::Backend::KeyValue.new(Redis.new(db: 0, password: Rails.application.secrets.redis_local_pw))
#I18n.backend= I18n::Backend::KeyValue.new(Redis.new(db: 0, password: Rails.application.secrets.redis_integration_pw))
#I18n.backend= I18n::Backend::KeyValue.new(Redis.new(db: 0, password: '123456')) if Rails.env ='development'

#this line below shows how to chain the backend so that anything msiing in redis may be found in yaml

=begin Use this for using yaml as an additional resource on local machine
I18n.backend= I18n::Backend::Chain.new(
   I18n::Backend::KeyValue.new(Redis.new(db: 0, password: Rails.application.secrets.redis_local_pw)),
   I18n.backend
   ) 
=end

#=begin This is the local server using redis only for translation
I18n.backend= I18n::Backend::KeyValue.new(Redis.new(db: 0, password: Rails.application.secrets.redis_local_pw))
#=end

=begin This is the integration server using redis only for translation
I18n.backend= I18n::Backend::KeyValue.new(Redis.new(db: 0, password: Rails.application.secrets.redis_integration_pw)) 
  
=end