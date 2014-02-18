class RenameCalmappVersionIdToCalmappVersionsTranslationLanguageInTranslationUploads < ActiveRecord::Migration
  def change
    rename_column :translations_uploads, :calmapp_version_id, :calmapp_versions_translation_language_id
  end
end
