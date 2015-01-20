class AlterTranslationHints < ActiveRecord::Migration
  
  def change
    add_column :translation_hints, :dot_key_code, :string, :unique=>true, :null=> false
  end

end
