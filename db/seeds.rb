if Rails.env.development?
  Card.delete_all
  User.delete_all
  (1..9).each do |num|
    user = User.create!(email: "test#{num}@test.com",
                        password: 'qweasd',
                        display_name: "test#{num}@test.com")
    user.cards.delete_all
    (1..20).each do |card_num|
      card = Card.new(question: "question#{card_num}",
                      answer: "answer#{card_num}")
      user.cards << card
    end
  end
end
