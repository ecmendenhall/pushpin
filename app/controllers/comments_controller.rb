class CommentsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
      @comment = current_user.comments.build(comment_params)
      if @comment.save
          flash[:success] = "Comment created!"
          redirect_back_or root_url
      else
          flash[:error] = "Your comment could not be saved."
          redirect_back_or root_url
      end
  end

  def destroy
      @comment.destroy
      redirect_to root_url
  end

  private
    
    def comment_params
        params.require(:comment).permit(:content, :link_id)
    end

    def correct_user
        @comment = current_user.comments.find(params[:id])
        redirect_to root_url if @comment.nil?
    end
end
