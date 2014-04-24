class RenameCdlrToCldrInSpecialPartialDotKeys < ActiveRecord::Migration
  def change
    rename_column :special_partial_dot_keys, :cdlr, :cldr
  end
end
