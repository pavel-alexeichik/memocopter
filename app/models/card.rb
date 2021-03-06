class Card < ApplicationRecord
  MIN_TRAINING_INTERVAL = 1.day
  INITIAL_TRAINING_INTERVAL = 1.day
  TRAINING_TIME_OFFSET = 12.hours

  belongs_to :user
  validates :question, presence: true
  validates :answer, presence: true
  before_create :initialize_training_interval, :initialize_next_training_time

  scope :ordered_by_created_at, -> { order(created_at: :desc) }
  scope :where_last_was_wrong, -> { where(last_was_wrong: true) }
  scope :where_last_was_right, -> { where(last_was_wrong: false) }

  def self.generate
    group = %w(fruit herb_or_spice ingredient meat vegetable).sample
    Card.new(question: FFaker::Food.send(group).humanize, answer: group.humanize)
  end

  def self.for_training
    offset = TRAINING_TIME_OFFSET.seconds.from_now
    for_training = where('next_training_time <= ?', offset)
    for_training.order(training_interval: :desc).where_last_was_right
  end

  def training_interval=(value)
    super [MIN_TRAINING_INTERVAL, value].max
  end

  def save_training_result(result)
    self.last_was_wrong = !result
    if next_training_time <= TRAINING_TIME_OFFSET.seconds.from_now
      self.training_interval *= result ? 2 : 0.75
      self.next_training_time = training_interval.seconds.from_now
    end
    save
  end

  private

  def initialize_training_interval
    self.training_interval ||= INITIAL_TRAINING_INTERVAL
  end

  def initialize_next_training_time
    self.next_training_time ||= created_at
  end
end
