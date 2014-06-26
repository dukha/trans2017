class AddCldrTypeToTranslationLanguage < ActiveRecord::Migration
  def change
    add_column :translation_languages, :plural_sort, :string, :null=>false, :default=> "one_other" #"CldrType.CLDR_PLURAL_TYPES[:one_other]"
  end
end
