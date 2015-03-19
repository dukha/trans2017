class RenameCalmappUserToCalmappDeveloper < ActiveRecord::Migration
  def change
    rename_table :calmapp_users, :calmapp_developers
    
  end
end
