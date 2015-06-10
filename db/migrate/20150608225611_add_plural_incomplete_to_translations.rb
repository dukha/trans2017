class AddPluralIncompleteToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :plural_incomplete, :boolean, :default => false
  end
end
