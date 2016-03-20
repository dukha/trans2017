class AddCreatedManuallyToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :created_manually, :boolean, :default => false, :null=> false
  end
end
