class ChangeVersionToStringInCalmappVersions < ActiveRecord::Migration
  def change
     remove_column :calmapp_versions, :version
     add_column :calmapp_versions, :version, :string
  end
end
