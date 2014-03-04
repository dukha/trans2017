class DropTranslationLanguageIdFromTranslationsUploads < ActiveRecord::Migration
  def up
    change_table :translations_uploads do |t|
     t.remove  :translation_language_id
    end
  end
  
  def down
    change_table :translations_uploads do |t|
     t.integer  :translation_language_id
    end
  end
end
