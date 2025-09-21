FactoryBot.define do
  factory :sleep do
    start { DateTime.now }
  end
end
