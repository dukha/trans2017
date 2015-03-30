class AddAttrProtectedToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :protected_profile, :boolean, :default=>false, :nullable=>false
  end
end
