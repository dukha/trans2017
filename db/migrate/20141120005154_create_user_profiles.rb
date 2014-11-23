class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.integer :user_id, :null=>false
      t.integer :profile_id, :null=>false
      t.index :profile_id, :unique => false
      t.index :user_id, :unique => false
      t.index [:user_id, :profile_id], :unique => true
      t.timestamps
    end
  end
end
