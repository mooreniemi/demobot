require 'faker'
FactoryGirl.define do
  factory :user do
    nickname "joe_stalin69"
    admin false
  end

  factory :cinch_user, class: OpenStruct do
    nick { Faker::Internet.user_name }
  end
end