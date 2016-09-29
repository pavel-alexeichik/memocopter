class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.references :user, null: false
      t.string :question, null: false
      t.string :answer, null: false
      t.timestamps
    end
    add_index :cards, :user
  end
end
