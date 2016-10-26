class FixLastWasWrongColumn < ActiveRecord::Migration[5.0]
  def change
    change_column :cards, :last_was_wrong, :boolean, default: false
  end
end
