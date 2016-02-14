class AddTranslatorsRedisDatabaseIdToCalmappVersion < ActiveRecord::Migration
  def change
    add_column :calmapp_versions, :translators_redis_database_id, :integer
    add_index :calmapp_versions, :translators_redis_database_id
  end
end
