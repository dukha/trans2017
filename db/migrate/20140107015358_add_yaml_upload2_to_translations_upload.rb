class AddYamlUpload2ToTranslationsUpload < ActiveRecord::Migration
  def change
    add_column :translations_uploads, :yaml_upload2, :string
  end
end
