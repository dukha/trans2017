class AddYamlUploadToTranslationsUpload < ActiveRecord::Migration
  def change
    add_column :translations_uploads, :yaml_upload, :string
  end
end
