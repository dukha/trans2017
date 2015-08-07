class RedisDatabase < ActiveRecord::Base
  include Validations
  extend SearchModel
  include SearchModel
  require 'connection_pool'
  
  attr_reader :pool_connection
  #validates :with => RedisDbValidator2
  #belongs_to :calmapp_version
  belongs_to :redis_instance#, :dependent => :restrict_with_exception
  belongs_to :calmapp_version, inverse_of: :redis_databases
  #belongs_to :calmapp_versions_redis_database
  #has_one :calmapp_versions_redis_database
  # has_one through does not permit multiple association instances in this direction. 
  # The association is not an array, even though the reverse association is a has_many through
  #has_one :calmapp_version, :through => :calmapp_versions_redis_database
  belongs_to :release_status
  #has_many :uploads_redis_databases
  #has_many :uploads, :through => :uploads_redis_databases
  #validates :calmapp_version_id, :presence=>true
  #validates :calmapp_version_id, :existence => true#, :presence=>true
  validates :redis_db_index, :presence=>true
  validates :redis_db_index, :uniqueness => {:scope=>[:redis_instance]}
  validates :redis_instance_id, :presence=>true
  validates :release_status, :presence=>true, :existence=>true
  #validates :release_status, :uniqueness=>{:scope=>[:calmapp_version]}
  #validate :redis_db_index_exists
  
  #validates :release_status_id, :existence=>true
  validates :calmapp_version_id,:presence=>true
  #validates :host,:presence=>true
  #validates :port, :presence => true
  
  #This validation checks whether the redis_db_index is one permitted by the installation.
  #Returns false if not. Default redis setup is for databases 0-15 to be available.
  #This can be increased in the redis config file (not via rails)
  #validates  :redis_db_index, :redis_db => true
  
  #validates_with Validations::TranslationValidator
  #after_save :name_database
  #before_delete -> (model) {model.calmapp_versions_redis_database.destroy}, :unless => model.calmapp_versions_redis_database.nil?}#:delete_calmapp_versions_redis_database
  #before_destroy :delete_calmapp_versions_redis_database
  after_create :after_create_method
=begin  
  executed after create. Creates a connection pool for redis db and deleted everything from redis database
=end  
  def after_create_method
    #pool()
    flush_redis()
  end
  def show_me
    redis_instance.show_me + ":" + "RDB index" + redis_db_index.to_s + " " + " rdb-id=" + id.to_s + " " + calmapp_version.show_me
  end
=begin
  gets the pool the connection pool 
=end  
  def pool
    pool_connection = ConnectionPool.new(size: 10, timeout: 5) do 
      Redis.new :db=> redis_db_index, :password=> redis_instance.password, :host=> redis_instance.host, :port=> redis_instance.port
    end 
    return pool_connection   
  end
  
  def flush_redis
    pool.with{|con| con.flushdb}
  end
  #@connection=nil
  def self.searchable_attr 
     %w(id  calmapp_version_id  )
  end
  def self.sortable_attr
      []
  end
  
  def description
    #binding.pry
    #db_name = calmapp_version.description + " / Redis Instance: " + short_name
    return short_name
    #binding.pry
    #connect.setname db_name
  end
  def short_name
    db_name = redis_instance.description + 
    ": DB Index: " + redis_db_index.to_s
  end

=begin 
  def connect
    #binding.pry
    #@connection is a singleton: only 1 connection per database" will need testing in a multiuser situation
    if ! @connection then
      @connection = new_connection
    end
    return @connection
  end
  
  def new_connection
    #con = Redis.new :db=> redis_db_index, :password=> redis_instance.password, :host=> redis_instance.host, :port=> redis_instance.port
    return con
  end
=end
  def database_supports_language? language
    if language.is_a?(TranslationLanguage) then
      language = language.id
    end
    return calmapp_version.language_ids.include? language
  end

  def redis_to_yaml 
    redis = Redis.new(:db=>redis_db_index, :host=>redis_instance.host, :port=> redis_instance.port, :password=>redis_instance.password )
    key_array= redis.keys('*')
    container = Hash.new
    key_array.each{ |k|
      emit_1_dot_key_value( k, redis.get(k), container)
    }
    puts container.to_yaml
    return container.to_yaml
  end
  
  def redis_instance_find
    if @redis_instance.nil? then
      @redis_instance = RedisInstance.find(redis_instance_id)
    end
    return @redis_instance  
  end
  

  def port
    return redis_instance.port
  end
  
  def host
    return redis_instance.host
  end
  
  def password
    return redis_instance.password
  end

  
=begin
 publishes 1 Translation to redis database
 does not disconnect 
=end  
  def publish_one_translation(translation) #, con = nil)
    #binding.pry
    translation = Translation.find(translation) if translation.is_a? Integer
    #binding.pry
    dot_key= translation.full_dot_key_code
=begin    
    if translation.translation.starts_with? '{' then
      # this is a plural written has a json hash in the relational db
      # We need to all the plurals as a hash in redis
      plurals = JSON.parse(translation.translation)
      pool.with{ |con| 
        plurals.each do |k,v|
          con.hset(dot_key, k, v)
        end  
        #con.hset(dot_key, plurals)
        puts "Published " + dot_key + " = " +  con.hgetall(dot_key).to_json
      }
    else
    #if dot_key == "ja.date.abbr_day_names"
      #binding.pry
    #end
    #connect.auth(password)
=end
      pool.with{ |con| 
        con.set(dot_key, translation.translation)
        puts "Published " + dot_key + " = " +  con.get(dot_key)
      }
    #end
    
  end

=begin
 removes 1 Translation from redis database 
=end   
  def unpublish_one_translation(translation)
    translation = Translation.find(translation) if translation.is_a? Integer
     dot_key= translation.full_dot_key_code
     pool.with{ |con| con.del(dot_key)}
  end
  


=begin
  First removes all existing translations in the redis database 
 publishes all translations(for all languages) for the calmapp_version of this redis_database 
=end  
  def publish_version 
    #con = nil
    count = 0
    begin
      translations  = Translation.join_to_cavs_tls_arr(calmapp_version.id)
      
      # This removes all key value pairs from the db
      pool.with{|con| 
        con.flushdb     
        translations.each{ |t|   
            publish_one_translation(t)#, con)
            count +=1      
          }
        con.bgsave
       }
    rescue StandardError => se
      raise se
    ensure
      #con.quit
    end     
    return count
  end  
  
  def self.validate_redis_db_params redis_db_id
    if redis_db_id.blank? then
      raise StandardError.new("Redis Database cannot be blank" )
    end
  end
=begin   
  First removes all existing translations in the redis database
 Publishes all translations for the given translation language
 @param TranslationLanguage instance 
=end  
  def publish_version_language translation_language
    #con = nil 
    count = 0
    begin
      #con = connect
      #binding.pry
      translations  = Translation.join_to_cavs_tls_arr(calmapp_version.id).joins_to_tl_arr.where{tl1.iso_code == translation_language.iso_code}
      pool.with{|con|
        translations.each{ |t|
          publish_one_translation(t)#, con)
          count += 1        
        }
        con.bgsave
      }
    rescue  StandardError => se
      raise se    
    ensure
      #con.quit
    end  
    return count  
  end  

  def self.demo
    marks_redis = RedisInstance.where { description =="Mark's Desktop Computer"}.first
    ri_integration = integration_instance
    calm = Calmapp.where(:name=>"calm_registrar").first
    #index = marks_redis.next_index
    RedisDatabase.create!(:redis_instance_id => marks_redis.id, release_status_id: ReleaseStatus.where{status == 'Development' }.first.id, calmapp_version_id: CalmappVersion.where(:calmapp_id => Calmapp.where(:name=>"translator").first.id, :version=>1).first.id, 
    :redis_db_index =>  0)
    #index = marks_redis.next_index(index)
    RedisDatabase.create!(:redis_instance_id => marks_redis.id, release_status_id: ReleaseStatus.where{status == 'Development' }.first.id, calmapp_version_id: CalmappVersion.where(:calmapp_id => calm.id, :version=>4).first.id, 
    :redis_db_index =>  1)
    
    RedisDatabase.create!(:redis_instance_id => ri_integration.id, release_status_id: ReleaseStatus.where{status == 'Integration' }.first.id, calmapp_version_id: CalmappVersion.where(:calmapp_id => Calmapp.where(:name=>"translator").first.id, :version=>1).first.id, 
    :redis_db_index =>  0)#ri_integration.next_index)
    RedisDatabase.create!(:redis_instance_id => ri_integration.id, release_status_id: ReleaseStatus.where{status == 'Integration' }.first.id, calmapp_version_id: CalmappVersion.where(:calmapp_id => calm.id, :version=>4).first.id, 
    :redis_db_index =>  1)
  end
  def self.marks_instance
    RedisInstance.where { description =="Mark's Desktop Computer"}.first
  end
  def self.integration_instance
    RedisInstance.where { description == 'Integration Server' }.first
  end
  
  def self.marks_trans_redis
    return RedisDatabase.where{redis_db_index == 0}.
            where{redis_instance_id == my{marks_instance.id}}.
            joins{calmapp_version.calmapp_versions_translation_languages.translation_language}.
            #where{calmapp_version.calmapp_versions_translation_languages.translation_language.iso_code == 'en'}.
            select{"calmapp_versions_translation_languages.id as cavtl_id, redis_db_index, redis_databases.id as id, redis_instance_id, redis_databases.calmapp_version_id as calmapp_version_id, release_status_id "}.
            first
  end
  
  def self.integration_trans_redis
    return RedisDatabase.where{redis_db_index == 0}.
            where{redis_instance_id == my{integration_instance.id}}.
            joins{calmapp_version.calmapp_versions_translation_languages.translation_language}.
            where{calmapp_version.calmapp_versions_translation_languages.translation_language.iso_code == 'en'}.
            select{"calmapp_versions_translation_languages.id as cavtl_id, redis_db_index, redis_databases.id as id, redis_instance_id, redis_databases.calmapp_version_id as calmapp_version_id, release_status_id "}.
            first
  end
  
  def self.integration_reg_redis
    return RedisDatabase.where{redis_db_index == 1}.
            where{redis_instance_id == my{integration_instance.id}}.
            joins{calmapp_version.calmapp_versions_translation_languages.translation_language}.
            where{calmapp_version.calmapp_versions_translation_languages.translation_language.iso_code == 'en'}.
            select{"calmapp_versions_translation_languages.id as cavtl_id, redis_db_index, redis_databases.id as id, redis_instance_id, redis_databases.calmapp_version_id as calmapp_version_id, release_status_id "}.
            first
  end
  
  def self.trans_uploads_for_demo
    upload_from_dir = upload_dir_for_demo
    files_to_upload =[File.join(upload_from_dir, 'common.en.yml'), 
                      File.join(upload_from_dir, 'devise_invitable.en.yml'),
                      File.join(upload_from_dir, 'devise.en.yml'),
                      File.join(upload_from_dir, 'translator.en.yml')  ]
  end
#=begin  
  def self.upload_dir_for_demo
    'config/locales'
  end  
#=end    
  
  def self.marks_big_demo    
    redis = marks_trans_redis
    files_to_upload = trans_uploads_for_demo
    count = 0
    files_to_upload.each{ |f|
      count += 1
      tu = TranslationsUpload.new(description: "self demo " +count.to_s, cavs_translation_language_id: redis.cavtl_id, yaml_upload: File.new(f) )
      tu.save!
    }
    redis.publish_version 
    puts "translator published locally via MARKS BIG DEMO" 
  end 
  
  def self.integ_big_demo
    binding.pry
    integ  = integration_trans_redis
    upload_from_dir = upload_dir_for_demo
    files_to_upload = trans_uploads_for_demo
    #binding.pry
    count = 0
    files_to_upload.each{ |f|
      count += 1
      tu = TranslationsUpload.new(description: "self demo integ " + count.to_s, cavs_translation_language_id: integ.cavtl_id, yaml_upload: File.new(f) )
      tu.save!
      }
    integration_trans_redis.publish_version
    puts "reg published on integration"
    integration_reg_redis.publish_version
    puts "reg published on integration via INTEG BIG DEMO"
  end
=begin

  # This method takes a key and value, for example from redis and puts it into container, in a form readily converted to yaml
  def emit_1_dot_key_value(dot_key, val, container)
    partial_keys = dot_key.split(".")
    traverse_dot_key( partial_keys, val, container)
  end

  def traverse_dot_key parts, val, container
    if parts.length > 0 then
      if  container.is_a? Hash then
        if  container.key? parts[0] then
          traverse_dot_key parts[1..parts.length-1],val, container[parts[0]]
          return
        else
          #parts[0] is not in Hash as key
          if parts.length == 1 then
            #last partial, so store the value
            container.store(parts[0], val)
            return
          elsif parts.length==2 then
            # check to see if we need to add an array or hash for the last container
            if parts[1] =~ /[0-9]{3}/ then
              # we are in a sequence coming up
              new_sub_container = Array.new
            else
              new_sub_container = Hash.new
            end
            #container.store(parts[0], new_sub_container)
          else
            # parts length is > 2 i.e. not a special case
            new_sub_container= Hash.new
          end
            container.store(parts[0], new_sub_container)
            traverse_dot_key(parts[1..(parts.length-1)], val, new_sub_container)
            return
        end
      elsif container.is_a? Array then
          container.push val
          return
      elsif container[parts[0]].is_a? String then
          # the key apparently has a value and so key is in error
          raise Exception.new("This key already has a value:" + parts.join( "."))
          return
      else
          # this is an error
          raise Exception.new( "There is a partial key that is wrong in the dot_key: Partial Key = " + parts[0] + " in dot key = " + parts.join("."))
          return
      end # pars[0] is hash

    else
      #empty array
      raise Exception.new( "Empty array passed with value " + val + " when parsing file.")
      return
    end
  end
=end
end


