class AddTrainingDataToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :next_training_time, :datetime
    add_column :cards, :training_interval, :integer
    add_index :cards, [:next_training_time, :training_interval]
    Card.update_all(next_training_time: Time.now)
    Card.update_all(training_interval: Card::INITIAL_TRAINING_INTERVAL)
  end
end
