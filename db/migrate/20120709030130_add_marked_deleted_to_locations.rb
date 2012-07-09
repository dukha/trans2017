class AddMarkedDeletedToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :marked_deleted, :boolean, :default=>false
  end

  def self.down
    remove_column :locations, :marked_deleted
  end
end
