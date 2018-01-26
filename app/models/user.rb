class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #   :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable, :rememberable,
         :recoverable, :trackable, :validatable

  has_many :cards

  validates :display_name, presence: true

  def self.create_guest
    user = User.create!(guest: true,
      email: FFaker::Internet.unique.email,
      password: FFaker::Internet.password,
      display_name: FFaker::Name.unique.name)
    20.times { user.cards << Card.generate }
    user
  end
end
