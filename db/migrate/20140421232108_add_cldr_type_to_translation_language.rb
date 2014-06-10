class AddCldrTypeToTranslationLanguage < ActiveRecord::Migration
  def change
    add_column :translation_languages, :cldr_type, :string, :default=>'one_other'
  end
end
