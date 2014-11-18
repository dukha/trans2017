class AlterUsersInvitable2 < ActiveRecord::Migration
  def change
  
    # Allow null username
    change_column :users, :username, :string, :null => true
  end


end
