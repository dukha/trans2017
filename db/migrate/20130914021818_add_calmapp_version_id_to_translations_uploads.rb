class AddCalmappVersionIdToTranslationsUploads < ActiveRecord::Migration
  def change
    add_column :translations_uploads, :calmapp_version_id, :integer
    add_index :translations_uploads, :calmapp_version_id
  end
end
