class CalmAttrForUsers < ActiveRecord::Migration
  def change
   add_column :users, :username, :string, :null=> false
   add_column :users, :actual_name, :string, :null=> false
   add_column :users, :current_permission_id, :integer
   add_index :users, :username, :unique=> true, :name=> :iu_username
      
  end
end