namespace :rss do
  desc "Refresh all user RSS feeds."
  task refresh_feeds: :environment do
    User.all.each do |user|
          Rails.logger.info "Refreshing feed for user #{user.pinboard}"
          user.get_new_links
      end
  end
end
