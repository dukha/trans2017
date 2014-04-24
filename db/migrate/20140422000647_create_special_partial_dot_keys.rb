class CreateSpecialPartialDotKeys < ActiveRecord::Migration
  def change
    create_table :special_partial_dot_keys do |t|
      t.string :partial_dot_key
      t.string :type
      t.boolean :cdlr

      t.timestamps
    end
    add_index :special_partial_dot_keys, :partial_dot_key
  end
end
