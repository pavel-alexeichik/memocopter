class User < ApplicationRecord
  has_many :cards_sets
  has_many :cards, through: :cards_sets

  validates :email, presence: true, uniqueness: true
  validates :display_name, presence: true
end
