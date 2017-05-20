class AddTmzDefaultToUsers < ActiveRecord::Migration
  def change
    change_column :users, :timezone_offset, :default => -600
  end
end
