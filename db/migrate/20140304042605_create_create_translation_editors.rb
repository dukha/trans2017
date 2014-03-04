class CreateCreateTranslationEditors < ActiveRecord::Migration
  def change
    create_table :create_translation_editors do |t|
      t.string :dot_key_code
      t.string :editor
      t.string :lambda

      t.timestamps
    end
  end
end
