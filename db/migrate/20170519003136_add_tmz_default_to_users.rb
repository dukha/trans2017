class AddTmzDefaultToUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :timezone_offset, -600
  end
end
