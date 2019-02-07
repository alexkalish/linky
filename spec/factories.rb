FactoryBot.define do

  factory :user do
    sequence(:email) { |n| "mickey.mouse+#{n}@magickingdom.com" }
    password { "password123" }
  end

  factory :link do
    sequence(:destination_url) { |n| "http://www.magickingdom.com/#{n}" }
    user
  end

end
