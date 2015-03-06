class ChangeRedisDatabases < ActiveRecord::Migration
  def change
    change_table :redis_databases do |t|
      t.references :release_status, index: true, required: true
      t.references :calmapp_version, index: true, required: true 
      
    end
  end
end
