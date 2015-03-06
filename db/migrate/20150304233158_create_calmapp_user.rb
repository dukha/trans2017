class CreateCalmappUser < ActiveRecord::Migration
  def change
    create_table :calmapp_users do |t|
      t.integer :calmapp_id, :nullable => false 
      t.integer :user_id, :nullable => false
    end
  end
end
