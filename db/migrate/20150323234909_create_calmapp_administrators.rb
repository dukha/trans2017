class CreateCalmappAdministrators < ActiveRecord::Migration
  def change
    create_table :calmapp_administrators do |t|
      t.integer :calmapp_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
