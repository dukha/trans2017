class AddWrittenToDbToTranslationsUploads < ActiveRecord::Migration
  def change
    add_column :translations_uploads, :written_to_db, :boolean
  end
end
