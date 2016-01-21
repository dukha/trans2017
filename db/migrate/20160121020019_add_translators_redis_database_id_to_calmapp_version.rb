class AddTranslatorsRedisDatabaseIdToCalmappVersion < ActiveRecord::Migration
  def change
    add_reference :calmapp_versions, :redis_databases, index: true
  end
end
