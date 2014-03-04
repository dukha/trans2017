class CreateTranslationEditors < ActiveRecord::Migration
  def change
    create_table :translation_editors do |t|
      t.string :dot_key_code
      t.string :editor
      t.string :lambda
      t.index :dot_key_code , :unique=> true, :name =>"uix_translation_editors_dot_key_code"
    end
  end
end
