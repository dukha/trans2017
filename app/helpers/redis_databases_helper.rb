module RedisDatabasesHelper

  def translator_publishing? rdb
    return "0" if rdb.nil? || rdb.new_record?
    cv = CalmappVersion.find(rdb.calmapp_version_id)
    return "1" if cv.translators_redis_database_id == rdb.id
    return "0"
  end
  
  
end

