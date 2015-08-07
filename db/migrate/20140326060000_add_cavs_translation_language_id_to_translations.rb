class AddCavsTranslationLanguageIdToTranslations < ActiveRecord::Migration
  def up
    #remove_index :translations, :name=>":iu_translations_language_dot_key_code"
    remove_column :translations, :language,:string
    add_column :translations, :cavs_translation_language_id, :integer, :nullable=>false
    add_index :translations, [:cavs_translation_language_id, :dot_key_code], :unique=> true, :name=> :iu_translations_language_dot_key_code
    add_index :translations, :cavs_translation_language_id, :unique=> false, :name=> :i_translations_language
    add_index :translations,  :dot_key_code,  :name=> :i_dot_key_code
  end
  
  def down
    remove_index :translations, :name=> "iu_translations_language_dot_key_code"
    add_column :translations, :language,:string
    add_index :translations, [:language, :dot_key_code], :unique=> true, :name=> :iu_translations_language_dot_key_code
  end
end
