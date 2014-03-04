class CreateCalmappVersionsRedisDatabases < ActiveRecord::Migration
  def change
    create_table :calmapp_versions_redis_databases do |t|
      t.integer :calmapp_version_id
      t.integer :redis_database_id
      t.integer :release_status_id
      t.index [:calmapp_version_id, :redis_database_id], :unique=> true, :name =>"uix_cav_rdb_on_calmapp_version_id_and_redis_database_id"
    end
  end
end
