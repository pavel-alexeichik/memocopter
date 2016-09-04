class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.string :question, null: false
      t.string :answer, null: false
      t.references :cards_set, foreign_key: true, null: false
      t.boolean :public, default: false
      t.integer :position, default: 0
      t.timestamps
    end
    add_foreign_key :cards, :cards_set
  end
end
