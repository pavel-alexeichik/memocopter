# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

if Rails.env.development?
  Card.delete_all
  User.delete_all
  (1..9).each do |num|
    user = User.create!(email: "test#{num}@test.com",
      display_name: "test#{num}@test.com",
      password: 'qweasd')
    user.cards.delete_all
    (1..20).each do |card_num|
      card = Card.new(question: "question#{card_num}",
        answer: "answer#{card_num}")
      user.cards << card
    end
  end
end
