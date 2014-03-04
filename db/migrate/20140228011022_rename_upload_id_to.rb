class RenameUploadIdTo < ActiveRecord::Migration
  def change
    rename_column :translations, :upload_id, :translations_upload_id
    remove_column :translations, :calmapp_version_id
  end
end
