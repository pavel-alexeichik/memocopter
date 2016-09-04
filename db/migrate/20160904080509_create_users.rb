class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.boolean :admin
      t.datetime :last_seen
      t.string :email
      t.string :display_name

      t.timestamps
    end
  end
end
