class ChangeTypeToSortInSpecialPartialDotKey < ActiveRecord::Migration
  def change
    rename_column :special_partial_dot_keys, :type, :sort
  end
end
