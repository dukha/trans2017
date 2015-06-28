class RenameCavTlAdministratorsToCavsTlAdministrators < ActiveRecord::Migration
  def change
    rename_table :cav_tl_administrators, :cavs_tl_administrators
  end
end
