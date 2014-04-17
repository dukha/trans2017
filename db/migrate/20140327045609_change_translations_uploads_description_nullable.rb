class ChangeTranslationsUploadsDescriptionNullable < ActiveRecord::Migration
  def change
    change_column :translations_uploads, :description, :string, :nullable=>true
  end
end
