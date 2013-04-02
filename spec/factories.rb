FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Beatrice #{n} Fastwater" }
    sequence(:email) { |n| "beatrice_#{n}@example.com"}   
    password "beatrice"
    password_confirmation "beatrice"
    pinboard "beatrice" 

    factory :admin do
        admin true
    end
  end

  factory :comment do
      content "Wow, great link!"
      sequence(:link_id)
      user
  end

  factory :link do
      user
      url "http://pielab.info"
      title "PieLab: Pies of tomorrow, today"
      description %{PieLab is an interdisciplinary research
                    group dedicated to the development of
                    experimental pies.}
      sequence(:datetime) { |n| "201#{n}-03-21T03:02:07Z".to_time }
    end
end
