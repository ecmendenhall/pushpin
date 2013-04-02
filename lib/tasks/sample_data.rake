namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
      make_users
      #make_links
      make_comments
      make_relationships
  end

  def make_users
    ecm = User.create!(name: "E.C. Mendenhall",
                       email: "e@cmendenhall.com",
                       password: "ecmendenhall",
                       password_confirmation: "ecmendenhall",
                       pinboard: "ecmendenhall")
    ecm.toggle!(:admin)

    users = ["maciej", "akohli", "wrdnrd", "twnbook", "mstmorris", "masukomi", "aardvark"]
    
    users.each do |user|
      name  = Faker::Name.name
      email = "#{user}@gmail.com"
      password  = "password"
      pinboard = user
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password,
                   pinboard: pinboard)
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
            user.links.create!(title: title,
                               url: url,
                               description: description,
                               datetime: datetime,
                               user_id: user.id) 
        end
    end
  end

  def make_comments
    users = User.all(limit: 6)
    10.times do
        content = Faker::Lorem.sentence(5)
        users.each { |user| user.comments.create!(content: content,
                                                  link_id: Link.all.sample.id) }
    end
  end

  def make_relationships
      users = User.all
      user = users.first
      followed_users = [2, 3, 5, 6]
      followers      = [4, 7, 8]
      followed_users.each { |followed| user.follow!(User.find(followed)) }
      followers.each      { |follower| User.find(follower).follow!(user) }
  end
end
