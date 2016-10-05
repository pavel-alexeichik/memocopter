FactoryGirl.define do
  factory :card do
    sequence(:question) { |n| "question#{n}" }
    sequence(:answer) { |n| "answer#{n}" }
    user

    factory :newest_card do
      created_at Time.now + 1.hour
    end
    factory :oldest_card do
      created_at Time.now - 1.year
    end
  end
end
