class AddApplicationAdministratorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :application_administrator, :boolean, :default => false, :nullable=> false
  end
end
