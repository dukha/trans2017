class CreateCavsTlTranslators < ActiveRecord::Migration
  def change
    create_table :cavs_tl_translators do |t|
      t.integer :cavs_translation_language_id, :null=> false
      t.integer :translator_id, :null=>false
      t.timestamps
    end
  end
end
