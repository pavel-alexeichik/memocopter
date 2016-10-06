FactoryGirl.define do
  factory :card do
    sequence(:question) { |n| "question#{n}" }
    sequence(:answer) { |n| "answer#{n}" }
    user

    factory :newest_card do
      created_at 1.hour.from_now
    end
    factory :oldest_card do
      created_at 1.year.ago
    end
  end
end
