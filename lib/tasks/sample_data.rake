namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
      make_users
      make_links
      make_comments
      make_relationships
  end

  def make_users
    beatrice = User.create!(name: "Beatrice Fastwater",
                            email: "beatrice@fw.com",
                            password: "beatrice",
                            password_confirmation: "beatrice")
    beatrice.toggle!(:admin)
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@pielab.info"
      password  = "password"
      pinboard = "pinboard#{n}"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
  end

  def make_links
    users = User.all(limit: 6)
    50.times do
        title = Faker::Lorem.sentence(5)
        url = "http://www.example.com"
        description = Faker::Lorem.paragraph(1)
        datetime = DateTime.now
        users.each do |user| 
            link_id = "#{user.pinboard}@013-03-21 01:55:11 UTC"
            user.links.create!(title: title,
                               url: url,
                               description: description,
                               datetime: datetime,
                               link_id: link_id,
                               user_id: user.id) 
        end
    end
  end

  def make_comments
    users = User.all(limit: 6)
    50.times do
        content = Faker::Lorem.sentence(5)
        users.each { |user| user.comments.create!(content: content,
                                                  link_id: "#{user}@2013-03-27T22:23:11Z") }
    end
  end

  def make_relationships
      users = User.all
      user = users.first
      followed_users = users[2..50]
      followers      = users[3..40]
      followed_users.each { |followed| user.follow!(followed) }
      followers.each      { |follower| follower.follow!(user) }
  end
end
