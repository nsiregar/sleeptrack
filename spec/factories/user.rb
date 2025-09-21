FactoryBot.define do
  factory :user do
    name { FFaker::Internet.unique.user_name }
  end
end
