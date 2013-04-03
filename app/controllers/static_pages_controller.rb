class StaticPagesController < ApplicationController
  def home
      store_location
      if signed_in?
        @comment = current_user.comments.build
        @feed_items = current_user.feed.paginate(page: params[:page])
      end
  end

  def help
  end
end
