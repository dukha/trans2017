class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :problem_area
      t.string :screen_name
      t.string :last_menu_choice
      t.text :description
      t.integer :user_id, :null=>false
      t.string :status, :default=> 'received'

      t.timestamps null: false
    end
  end
end
