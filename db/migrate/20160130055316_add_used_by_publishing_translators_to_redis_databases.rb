class AddUsedByPublishingTranslatorsToRedisDatabases < ActiveRecord::Migration
  def change
    add_column :redis_databases, :used_by_publishing_translators, :integer, :default=> -1, :null => false
    
  end
end
