class AlterRedisDatabasesReleaseStatusIdNull < ActiveRecord::Migration
  def change
    change_column :redis_databases, :release_status_id, :integer, :null =>true
  end
end
