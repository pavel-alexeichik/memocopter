class Card < ApplicationRecord
  belongs_to :cards_set

  validates :question, presence: true
  validates :answer, presence: true
end
