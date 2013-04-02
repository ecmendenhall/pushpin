FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Beatrice #{n} Fastwater" }
    sequence(:email) { |n| "beatrice_#{n}@example.com"}   
    password "beatrice"
    password_confirmation "beatrice"

    factory :admin do
        admin true
    end
  end

  factory :comment do
      content "Wow, great link!"
      link_id "user@2013-03-27T22:23:11Z"
      user
  end
end
