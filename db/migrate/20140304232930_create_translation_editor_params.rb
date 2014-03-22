class CreateTranslationEditorParams < ActiveRecord::Migration
  def change
    create_table :translation_editor_params do |t|
      t.integer :translation_editor_id
      t.string :param_name
      t.string :param_sequence
      t.string :param_default

      t.timestamps
    end
  end
end
