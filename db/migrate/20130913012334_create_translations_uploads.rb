class CreateTranslationsUploads < ActiveRecord::Migration
  def change
    create_table :translations_uploads do |t|
      t.integer :translation_language_id
      t.string :description

      t.timestamps
    end
  end
end
