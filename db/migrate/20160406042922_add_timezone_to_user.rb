class AddTimezoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :timezone_offset, :integer, :null=>true
  end
end
