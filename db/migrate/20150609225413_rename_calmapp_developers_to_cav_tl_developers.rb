class RenameCalmappDevelopersToCavTlDevelopers < ActiveRecord::Migration
  def change
    rename_table(:calmapp_developers, :cav_tl_developers)
  end
end
RenameCalmappDevelopersToCavTlDevelopers