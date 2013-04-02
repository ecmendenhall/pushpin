namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    beatrice = User.create!(name: "Beatrice Fastwater",
                            email: "beatrice@fw.com",
                            password: "beatrice",
                            password_confirmation: "beatrice")
    beatrice.toggle!(:admin)
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@pielab.info"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
  end
end
