class AddLastWasWrongColumnToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :last_was_wrong, :boolean, deafult: false
    add_index :cards, :last_was_wrong
  end
end
