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
end
