class AddDeveloperToUsers < ActiveRecord::Migration
  def change
    add_column :users, :developer, :boolean, :nullable => false, :default=> false
  end
end
