class CreateTranslationHints < ActiveRecord::Migration
  def change
    create_table :translation_hints do |t|
      t.string :dot_key_code, :string, :unique=>true, :null=> false
      t.string :heading
      t.string :example
      t.string :description
      
      t.timestamps
    end
  end
end
