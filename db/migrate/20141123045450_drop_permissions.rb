class DropPermissions < ActiveRecord::Migration
  def up
    drop_table :permissions
    remove_column :users, :current_permission_id
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
