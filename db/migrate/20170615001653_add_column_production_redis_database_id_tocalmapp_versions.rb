class AddColumnProductionRedisDatabaseIdTocalmappVersions < ActiveRecord::Migration
  def change
    add_column :calmapp_versions, :production_redis_database_id, :integer, :null => true
    add_index :calmapp_versions,  :production_redis_database_id
  end
  
end
