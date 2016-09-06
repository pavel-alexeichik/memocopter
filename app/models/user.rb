class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #  :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :cards_sets
  has_many :cards, through: :cards_sets

  validates :display_name, presence: true

end
