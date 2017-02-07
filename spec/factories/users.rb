FactoryGirl.define do
  factory :user do
    display_name 'John Hopkins'
    sequence(:email) { |n| "john.hopkins#{n}@test.com" }
    password 'qweasd'
    password_confirmation 'qweasd'

    factory :admin_user do
      email 'admin_user_email@test.com'
      admin true
    end

    factory :user_with_cards do
      transient { cards_count 5 }
      after(:create) do |user, evaluator|
        create_list(:card, evaluator.cards_count, user: user)
      end

      factory :default_user do
        email 'default_user_email@test.com'
      end

      factory :second_user do
        email 'second_user_email@test.com'
      end
    end
  end
end
