class AddRespondsToContactsToUser < ActiveRecord::Migration
  def change
    add_column :users, :responds_to_contacts, :boolean, :default=> false
  end
end
