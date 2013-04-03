class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index, :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
      @users = User.paginate(page: params[:page])
  end

  def show
      @user = User.find(params[:id])
      @links = @user.links.paginate(page: params[:page], per_page: 20)
  end

  def new
      @user = User.new
  end

  def create
      @user = User.new(user_params)
      if @user.save
          sign_in @user
          flash[:success] = render_to_string(partial: 'shared/welcome').html_safe 
          redirect_to @user
      else
          render 'new'
      end
  end

  def edit
      @user = User.find(params[:id])
  end

  def update
      if @user.update_attributes(user_params)
          flash[:success] = "Profile updated."
          sign_in @user
          redirect_to @user
      else
          render 'edit'
      end
  end

  def destroy
      User.find(params[:id]).destroy
      flash[:success] = "User destroyed."
      redirect_back_or users_url
  end

  def following
      @title = "Following"
      @user = User.find(params[:id])
      @users = @user.followed_users.paginate(page: params[:page])
      render 'show_follow'
  end 

  def followers
      @title = "Followers"
      @user = User.find(params[:id])
      @users = @user.followers.paginate(page: params[:page])
      render 'show_follow'
  end

  def links
      @user = User.find(params[:id])
      @links = @user.links.paginate(page: params[:page], per_page: 20)
  end

  def comments
      @user = User.find(params[:id])
      @comments = @user.comments.paginate(page: params[:page], per_page: 20)
  end

  private
    
    def user_params
        params.require(:user).permit(:name, 
                                     :email, 
                                     :password,
                                     :password_confirmation,
                                     :pinboard,
                                     :api_token)
    end

    def correct_user
        @user = User.find(params[:id])
        redirect_to(root_path) unless current_user?(@user)
    end

end
