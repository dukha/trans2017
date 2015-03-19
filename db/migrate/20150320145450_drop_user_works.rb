class DropUserWorks < ActiveRecord::Migration
  def up
    drop_table :user_works
    
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
