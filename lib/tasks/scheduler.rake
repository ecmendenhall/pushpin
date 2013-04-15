desc "Refresh all user RSS feeds."
task refresh_feeds: :environment do
  User.all.each do |user|
        Rails.logger.info "Refreshing feed for user #{user.pinboard}"
        user.delay.get_new_links
    end
end
