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

  def process_confirmation
      user = User.find_by(email: params[:confirm][:email].downcase)
      confirm_type = params[:type]
      confirm_code = params[:code]
      if confirm_type == "email"
          confirm_and_sign_in(user, :email, confirm_code)
      elsif confirm_type == "pinboard"
          confirm_and_sign_in(user, :pinboard, confirm_code)
      else
          redirect_to root_url
      end
  end

  def confirm
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

    def confirm_and_sign_in(user, confirm_type, user_code)
      if user && user.authenticate(params[:confirm][:password])
          if confirm_type == :email
              if user.email_confirmation_code == user_code
                  user.email_confirmed = true
                  user.save
                  sign_in user
                  flash[:success] = "Thanks! Your email address is confirmed."
                  redirect_to root_url
              else
                  flash.now[:error] = "Wrong authentication code."
              end
    
          elsif confirm_type == :pinboard
              if user.pinboard_confirmation_code == user_code
                  user.pinboard_confirmed = true
                  user.save
                  sign_in user
                  flash[:success] = "Thanks! Your Pinboard username is confirmed."
                  redirect_to root_url
              else
                  flash.now[:error] = "Wrong authentication code."
              end
          end
      else
          flash.now[:error] = 'Invalid email/password combination'
          render 'confirm'
      end
  end
end
