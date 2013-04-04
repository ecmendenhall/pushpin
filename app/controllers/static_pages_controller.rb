class StaticPagesController < ApplicationController
  def home
      store_location
      if signed_in?
        unless active_user?
          redirect_to confirm_status_user_path(current_user)
        end
        @comment = current_user.comments.build
        @feed_items = current_user.feed.paginate(page: params[:page])
      end
  end

  def help
  end
end
