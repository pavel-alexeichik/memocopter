class AddGuestColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :guest, :boolean, default: false
    add_index :users, :guest
  end
end
