class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #   :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable, :rememberable,
         :recoverable, :trackable, :validatable

  has_many :cards

  validates :display_name, presence: true
end
