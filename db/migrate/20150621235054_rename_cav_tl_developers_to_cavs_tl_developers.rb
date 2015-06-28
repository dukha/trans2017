class RenameCavTlDevelopersToCavsTlDevelopers < ActiveRecord::Migration
  def change
    rename_table :cav_tl_developers, :cavs_tl_developers
  end
end
