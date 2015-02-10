class ChangeRolesToRoolsUsers  < ActiveRecord::Migration
  def change  
    rename_column(:profiles, :roles, :rools)
  end
end
