class CreateDkcTranslationEditors < ActiveRecord::Migration
  def change
    create_table :dot_key_code_translation_editors do |t|
      t.string :dot_key_code
      t.string :editor
      
      t.timestamps
    end
  end
end
