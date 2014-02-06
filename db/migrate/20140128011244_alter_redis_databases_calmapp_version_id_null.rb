class AlterRedisDatabasesCalmappVersionIdNull < ActiveRecord::Migration
  def change
    change_column :redis_databases, :calmapp_version_id, :integer, :null =>true
  end
end
