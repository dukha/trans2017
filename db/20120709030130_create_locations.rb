class CreateLocations < ActiveRecord::Migration
  def self.up
    #add_column :locations, :marked_deleted, :boolean, :default=>false
    create_table :locations do |t|
      
      t.string :name,    :null=> false
      t.string :type, :null=> false
      t.string :parent_id 
      t.string :translation_code 
      t.boolean :marked_deleted, :null=> false
      t.string :fqdn
      t.timestamps
    end  
  end

  def self.down
    drop_table :locations
  end
end
