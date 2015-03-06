class AddCopiedFromVersionToCalmappVersion < ActiveRecord::Migration
  def change
    add_column :calmapp_versions, :copied_from_version, :string
  end
end
