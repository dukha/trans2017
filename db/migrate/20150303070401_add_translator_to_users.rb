class AddTranslatorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :translator, :boolean, :nullable => false, :default=> false
  end
end
