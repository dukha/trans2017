class AddPluralToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :plural, :boolean#, :default=> false
  end
end
