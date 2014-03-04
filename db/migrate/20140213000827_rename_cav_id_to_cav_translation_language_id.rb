class RenameCavIdToCavTranslationLanguageId < ActiveRecord::Migration
  def change
    rename_column :translations_uploads, :calmapp_version_id, :cavs_translation_language_id
  end
end
