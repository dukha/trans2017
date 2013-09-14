class TranslationLanguages < ActiveRecord::Migration
  def up
   create_table :translation_languages do |t|
      t.string :iso_code, :null=>false
      t.string :name, :null=>false
      

      t.timestamps
    end
    add_index :translation_languages, :name, {:unique=>true, :name=> "iu_tlanguages_name"}
    add_index :translation_languages, :iso_code, {:unique=>true, :name=> "iu_tlanguages_iso_code"}
  end
  
  def down
    drop_table :translation_languages
  end
end
