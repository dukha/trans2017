class AddAttachmentYamlUploadToTranslationsUploads < ActiveRecord::Migration
  def self.up
    change_table :translations_uploads do |t|
      t.attachment :yaml_upload
    end
  end

  def self.down
    drop_attached_file :translations_uploads, :yaml_upload
  end
end
