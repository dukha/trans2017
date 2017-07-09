class AddColumnUsedByProductionPublishersToRedisDatabases < ActiveRecord::Migration
  def change
    add_column :redis_databases, :used_by_production_publishers, :integer, :default=> -1, :null => false
  end
end
