class AddLanguageToTranslations < ActiveRecord::Migration
  def up
    add_column :translations, :language, :string
    remove_index :translations, :name=> :iu_translations_dot_key_code
    add_index :translations, [:language, :dot_key_code], :unique=> true, :name=> :iu_translations_language_dot_key_code
    add_index :translations, :dot_key_code, :unique=> false, :name=> "i_translations_dot_key_code"
  end
  
  def down
    remove_index :translations, name: iu_translations_language_dot_key_code
    remove_index :translations,  name: i_translations_dot_key_code
    remove_column :translations, :language
    add_index :translations, :dot_key_code, name: iu_translations_dot_key_code, :unique=> true
    
  end
end
