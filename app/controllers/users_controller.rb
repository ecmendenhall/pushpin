class UsersController < ApplicationController
  include UsersHelper
  before_action :active_user, except: [:confirm_status,  :confirm, :process_confirmation,
                                       :reconfirm_email, :reconfirm_pinboard, :edit, :update]
  before_action :signed_in_user, only: [:edit, :update, :index, :show, 
                                        :links, :comments, :following, :followers]
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
          post_pinboard_confirm_link @user
          UserMailer.confirm_email(@user).deliver
          sign_in @user
          flash[:success] = render_to_string(partial: 'shared/welcome').html_safe 
          redirect_to confirm_status_user_path(@user)
      else
          render 'new'
      end
  end

  def process_confirmation
      @user = User.find_by(email: params[:confirm][:email].downcase)
      confirm_type = params[:type]
      confirm_code = params[:code]
      if confirm_type == "email"
          confirm_and_sign_in(@user, :email, confirm_code)
      elsif confirm_type == "pinboard"
          confirm_and_sign_in(@user, :pinboard, confirm_code)
      else
        redirect_to root_url
      end
  end

  def confirm
  end

  def confirm_status
      @user = User.find(params[:id])
  end

  def edit
      @user = User.find(params[:id])
  end

  def update
      @user.attributes=(user_params)
      if @user.email_changed?
        @user.save
        redirect_to reconfirm_email_user_path(@user)
      elsif @user.pinboard_changed?
        @user.save
        redirect_to reconfirm_pinboard_user_path(@user)
      else
        if @user.save
            flash[:success] = "Profile updated."
            sign_in @user
            redirect_to @user
        else
            render 'edit'
        end
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

  def reconfirm_email
      @user = User.find(params[:id])
      @user.email_confirmed = false
      new_code = @user.new_confirm_code
      if @user.update_attribute(:email_confirmation_code, new_code)
        UserMailer.confirm_email(@user).deliver
        flash[:success] = "Sent a new confirmation email to #{@user.email}."
        redirect_to confirm_status_user_path(@user)
      else
        flash[:error] = "An error occurred."
        redirect_to confirm_status_user_path(@user)
      end
  end

  def reconfirm_pinboard
      @user = User.find(params[:id])
      @user.pinboard_confirmed = false
      new_code = @user.new_confirm_code
      if @user.update_attribute(:pinboard_confirmation_code, new_code)
        post_pinboard_confirm_link @user
        flash[:success] = "Saved a new confirmation link to your Pinboard bookmarks."
        redirect_to confirm_status_user_path(@user)
      else
        flash[:error] = "An error occurred."
        redirect_to confirm_status_user_path(@user)
      end
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
                  if user.update_attribute(:email_confirmed, true)
                    sign_in user
                    flash[:success] = "Thanks! Your email address is confirmed."
                    redirect_to root_url
                  else
                      flash[:error] = "Your email could not be confirmed."
                      redirect_to confirm_status_user_path(user)
                  end
              else
                flash.now[:error] = "Wrong authentication code."
                redirect_to root_url
              end
    
          elsif confirm_type == :pinboard
              if user.pinboard_confirmation_code == user_code
                  if user.update_attribute(:pinboard_confirmed, true)
                    sign_in user
                    remove_pinboard_confirm_link user
                    flash[:success] = "Thanks! Your Pinboard username is confirmed."
                    redirect_to root_url
                  else
                    flash[:error] = "Your Pinboard username could not be confirmed."
                    redirect_to confirm_status_user_path(user)
                  end
              else
                flash.now[:error] = "Wrong authentication code."
                redirect_to root_url
              end
          end
      else
          flash.now[:error] = 'Invalid email/password combination'
          render 'confirm'
      end
  end

end
