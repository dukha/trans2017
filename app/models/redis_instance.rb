# == Schema Information
#
# Table name: redis_instances
#
#  id       :integer         not null, primary key
#  host     :string(255)     not null
#  port     :integer         not null
#  password :string(255)     not null
#
=begin
  Redis.new(options)

  :path (def= nil may be only usable for sockets??
  or
  :host def =127.0.0.1
  and
  :port (def=6379)
  :db (def=0)
  :timeout
  :password
  :logger
=end
# todo Add max number of permitted redis databases as an attr. 
# This must be set first in redis.conf for the instance
class RedisInstance < ActiveRecord::Base
  
  include Validations
  has_many :redis_databases
  
  
  validates :host,:presence=>true
  validates :port, :presence => true
  validates :password, :presence=>true
  validates :max_databases, :presence=>true
  
  # a generalised validation for the record. Checks the attributes to see if it can connect to the instance
  validates  :host, :redis_instance => true
  
  #validates :host, :exclusion => { in: ['localhost', 'Localhost', 'LOCALHOST'], message: "%{value} is not permitted." }
  validate :not_localhost
  
  after_initialize :default_values
=begin
  def name
    return CalmappVersion.find(calmapp_version_id).name + " / Redis Database Index: " + redis_db_index.to_s
  end
=end

  def database_supports_language? language
    if language.is_a(TranslationLanguage) then
      language = language.id
    end
    return calmapp_version.language_ids.include? language
  end
  
  def unused_redis_database_indexes() 
    ar = (0..(max_databases - 1)).to_a
    #binding.pry
    redis_databases.each{|rdb| ar.delete(rdb.redis_db_index)}
    return ar
  end
  
  def next_index last_index = -1
    indexes = unused_redis_database_indexes()
    if not indexes.empty? then
      if last_index == -1 then
        ret_val = indexes[0] 
      elsif indexes.last == last_index then
        # This is an error condition: Not enough redis database
        #binding.pry
        raise Exceptions::NoRedisDatabasesLeft.new({description: description})
      else   
        indexes.delete_if {|el| el <= last_index}
        ret_val = indexes[0]
      end  
    else
      # This is an error condition: Not enough redis database
      #binding.pry
      raise Exceptions::NoRedisDatabasesLeft.new({description: description})
    end #not empty
  end
  
  def self.demo
    marks_redis = RedisInstance.create!(:host=>"45-highfield.internode.on.net", :password => '123456', :port => '6379', :max_databases=>16, :description=> "Mark's Desktop Computer")
    ri_integration = RedisInstance.create!(:host=>"31.222.138.180", :password => '123456', :port => '6379', :max_databases=>32, :description=>'Integration Server')
  end
  
  private
    def default_values
      return unless new_record?
      self.port ||= 6379
      self.max_databases ||= 16
    end
    
    def not_localhost
      if host.downcase == 'localhost' or host.start_with?('127.') or host.start_with?('10')  then
        errors.add(:host, "can't refer to localhost. Give the public IP address")
      end 
    end
end




# == Schema Information
#
# Table name: redis_instances
#
#  id       :integer         not null, primary key
#  host     :string(255)     not null
#  port     :integer         not null
#  password :string(255)     not null
#

