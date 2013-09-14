class AddCalmappVersionIdToTranslationsUploads < ActiveRecord::Migration
  def change
    add_column :translations_uploads, :calmapp_version_id, :integer
  end
end
