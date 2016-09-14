FactoryGirl.define do
  factory :card do
    sequence(:question) { |n| "question#{n}" }
    sequence(:answer) { |n| "answer#{n}" }
    user
  end
end
