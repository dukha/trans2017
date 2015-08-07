class AddPluralToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :special_structure, :string#, :default=> false
    add_index :translations, :special_structure,  :name=> :i_special_structure
  end
end
