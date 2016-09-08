FactoryGirl.define do
  factory :user do
    display_name 'John Hopkins'
    sequence(:email) { |n| "john.hopkins#{n}@test.com" }
    password 'qweasd'
    password_confirmation 'qweasd'
  end
end
