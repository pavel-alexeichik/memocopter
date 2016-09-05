class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.boolean :admin, default: false
      t.datetime :last_seen
      t.string :email, null: false
      t.string :display_name, null: false

      t.timestamps
    end
  end
end
