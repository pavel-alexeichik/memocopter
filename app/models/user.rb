class User < ApplicationRecord
  has_many :cards_sets
  has_many :cards, through: :cards_sets
end
