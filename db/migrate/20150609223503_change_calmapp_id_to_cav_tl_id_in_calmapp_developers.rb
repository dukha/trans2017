class ChangeCalmappIdToCavTlIdInCalmappDevelopers < ActiveRecord::Migration
  def change
    rename_column :calmapp_developers, :calmapp_id, :cavs_translation_language_id
  end
end
#change_calmapp_developers_to_calmapp_version_id_in_calmapp_developers