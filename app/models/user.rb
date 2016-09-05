class User < ApplicationRecord
  has_many :cards_sets
  has_many :cards, through: :cards_sets

  validates_presence_of :email
  validates_uniqueness_of :email, case_sensitive: false
  validates :display_name, presence: true

end
