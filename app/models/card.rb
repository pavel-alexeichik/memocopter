class Card < ApplicationRecord
  MIN_TRAINING_INTERVAL = 1.day
  INITIAL_TRAINING_INTERVAL = 1.day
  TRAINING_TIME_OFFSET = 12.hours

  belongs_to :user
  validates :question, presence: true
  validates :answer, presence: true
  before_create :initialize_training_interval, :initialize_next_training_time  

  scope :ordered_by_created_at, -> { order created_at: :desc }

  def self.for_training
    for_training = where('next_training_time <= ?', TRAINING_TIME_OFFSET.seconds.from_now)
    for_training.order(training_interval: :desc)
  end

  def training_interval=(value)
    super [MIN_TRAINING_INTERVAL, value].max
  end

  def save_training_result(result)
    return if next_training_time > TRAINING_TIME_OFFSET.seconds.from_now
    if result
      self.training_interval *= 2
    else
      self.training_interval *= 0.75
    end
    self.next_training_time = training_interval.seconds.from_now
    save
  end

  private
  def initialize_training_interval
    self.training_interval ||= INITIAL_TRAINING_INTERVAL
  end

  def initialize_next_training_time
    self.next_training_time = created_at
  end
end
