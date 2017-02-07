if Rails.env.development?
  Card.delete_all
  User.delete_all
  (1..9).each do |num|
    email = "test#{num}@test.com"
    password = 'qweasd'
    user = User.create!(email: email,
                        password: password,
                        display_name: email,
                        admin: num == 1)
    user.cards.delete_all
    (1..20).each do |card_num|
      card = Card.new(question: "question#{card_num}",
                      answer: "answer#{card_num}")
      user.cards << card
    end
    puts "User #{email} created with password #{password}"
  end
end
