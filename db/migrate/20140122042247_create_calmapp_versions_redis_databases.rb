class CreateCalmappVersionsRedisDatabases < ActiveRecord::Migration
  def change
    create_table :calmapp_versions_redis_databases do |t|
      t.integer :calmapp_version_id
      t.integer :redis_database_id
      t.integer :release_status_id
    end
  end
end
