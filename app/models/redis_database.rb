class RedisDatabase < ActiveRecord::Base
  include Validations
  #validates :with => RedisDbValidator2
  #belongs_to :calmapp_version
  belongs_to :redis_instance
  #belongs_to :calmapp_versions_redis_database
  has_one :calmapp_versions_redis_database
  # has_one through does not permit multiple association instances in this direction. 
  # The association is not an array, even though the reverse association is a has_many through
  has_one :calmapp_version, :through => :calmapp_versions_redis_database
  #belongs_to :release_status
  #has_many :uploads_redis_databases
  #has_many :uploads, :through => :uploads_redis_databases
  #validates :calmapp_version_id, :presence=>true
  #validates :calmapp_version_id, :existence => true#, :presence=>true
  validates :redis_db_index, :presence=>true
  validates :redis_db_index, :uniqueness => {:scope=>[:redis_instance]}
  validates :redis_instance_id, :presence=>true
  #validates :release_status, :presence=>true, :existence=>true
  #validates :release_status, :uniqueness=>{:scope=>[:calmapp_version]}
  #validate :redis_db_index_exists
  
  #validates :release_status_id, :existence=>true
  #validates :calmapp_version_id,:presence=>true
  #validates :host,:presence=>true
  #validates :port, :presence => true
  
  #This validation checks whether the redis_db_index is one permitted by the installation.
  #Returns false if not. Default redis setup is for databases 0-15 to be available.
  #This can be increased in the redis config file (not via rails)
  #validates  :redis_db_index, :redis_db => true
  
  #validates_with Validations::TranslationValidator
  #after_save :name_database
  #before_delete -> (model) {model.calmapp_versions_redis_database.destroy}, :unless => model.calmapp_versions_redis_database.nil?}#:delete_calmapp_versions_redis_database
  before_destroy :delete_calmapp_versions_redis_database
  @connection=nil
=begin
  def save!
    if new_record?
      state='new'
    end
    super
    new_record state
  end
  def save
    if new_record?
      state='new'
    end
    result = super
    new_record state
  end 
  def new_record state
    if state=='new' then
      redis = connect
      redis.flushdb
      temp_redis = Redis.new :db=> 0, :password=> redis_instance.password, :host=> redis_instance.host, :port=> redis_instance.port 
      temp_redis.set name, redis_db_index
    end
  end
=end
  def delete_calmapp_versions_redis_database
      calmapp_versions_redis_database.destroy
  end
  
  def name_database
    #binding.pry
    db_name = calmapp_version.name + " / Redis Instance: " + redis_instance.description + #RedisInstance.find(redis_instance_id).description + 
    " / Redis Database Index: " + redis_db_index.to_s
    #binding.pry
    #connect.setname db_name
  end
  #def name
    ##end
  # returns an instance of Redis class
  # use this singleton for very short transaction. May not be a good idea
  def connect
    #binding.pry
    #@connection is a singleton: only 1 connection per database" will need testing in a multiuser situation
    if ! @connection then
      @connection = new_connection
    end
    return @connection
  end
  
  def new_connection
    con = Redis.new :db=> redis_db_index, :password=> redis_instance.password, :host=> redis_instance.host, :port=> redis_instance.port
    #con.auth(password)
    #con.select con.db
    return con
  end

  def database_supports_language? language
    if language.is_a?(TranslationLanguage) then
      language = language.id
    end
    return calmapp_version.language_ids.include? language
  end

  def redis_to_yaml #file
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
  def publish_one_translation(translation, connection)
    #binding.pry
    translation = Translation.find(translation) if translation.is_a? Integer
    #binding.pry
    dot_key= translation.full_dot_key_code
    #connect.auth(password)
    connection.set(dot_key, translation.translation.to_json)
    puts "Published " + dot_key + " = " + connect.get(dot_key)
    
  end

=begin
 removes 1 Translation from redis database 
=end   
  def unpublish_one_translation(translation)
    translation = Translation.find(translation) if translation.is_a? Integer
     dot_key= translation.full_dot_key_code
     connect.del(dot_key)
  end
  
=begin
  
=end
  def publish_version_language(calmapp_versions_translation_language)
    #raise "Languages don't match" if 
    
  end

=begin
 publishes all translations(for all languages) for the calmapp_version of this redis_database 
=end  
  def publish_version 
    #calmapp_version.translation_languages.each{ |tl|
      #translations  = Translation.join_to_cavs_tls_arr(calmapp_version.id).joins_to_tl_arr.where{tl1.iso_code == tl}
      #translations.each{ |t|
        #t.publish_translation(id)         
      #}
      
    #}
    
    translations  = Translation.join_to_cavs_tls_arr(calmapp_version.id)
    #binding.pry
    con = new_connection
    # This removes all key value pairs from the db
    con.flushdb 
    count = 0
    translations.each{ |t|
        #t.publish_translation(id)   
        publish_one_translation(t, con)
        count +=1      
      }
    con.bgsave
    con.quit  
    return count
  end  

=begin
 Publishes all translations for the given translation language
 @param TranslationLanguage instance 
=end  
  def publish_version_language translation_language
      translations  = Translation.join_to_cavs_tls_arr(calmapp_version.id).joins_to_tl_arr.where{tl1.iso_code == transaltion_language.iso_code}
      translations.each{ |t|
        #t.publish_translation(id) 
        publish_one_translation(t)        
      }
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





# == Schema Information
#
# Table name: redis_databases
#
#  id                 :integer         not null, primary key
#  calmapp_version_id :integer         not null
#  redis_instance_id  :integer
#  redis_db_index     :integer         not null
#  release_status_id  :integer         not null
#  created_at         :datetime
#  updated_at         :datetime
#

