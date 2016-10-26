class AddLastWasWrongColumnToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :last_was_wrong, :boolean, default: false
    add_index :cards, :last_was_wrong
  end
end
