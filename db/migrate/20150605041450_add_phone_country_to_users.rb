class AddPhoneCountryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string 
    add_column :users, :country, :string
  end
end
