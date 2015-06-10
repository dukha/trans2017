class RenameCalmappAdministratorsToCavTlAdministrators < ActiveRecord::Migration
  def change
    rename_table(:calmapp_administrators, :cav_tl_administrators)
  end
end
