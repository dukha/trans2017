class AddPluralIncompleteToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :incomplete, :boolean, :default => false
    add_index :translations, :incomplete,  :name=> :i_incomplete
  end
end
