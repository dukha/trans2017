class RemoveReleaseStatusIdAndCalmappVersionIdFromRedisDatabases < ActiveRecord::Migration
  def change
    remove_column :redis_databases, :release_status_id, :integer
    remove_column :redis_databases, :calmapp_version_id, :integer
  end
end
