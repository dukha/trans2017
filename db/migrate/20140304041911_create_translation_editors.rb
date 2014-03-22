class CreateTranslationEditors < ActiveRecord::Migration
  def change
    create_table :translation_editors do |t|
      t.string :dot_key_code
      t.string :editor
      
      t.timestamps
    end
  end
end
