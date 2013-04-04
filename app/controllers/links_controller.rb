class LinksController < ApplicationController
    before_action :active_user
    before_action :signed_in_user
    before_action :correct_user,   only: :destroy

    require 'net/http'
    
    def show
        store_location
        @link = Link.find(params[:id])
        @user = @link.user
    end

    def share
        @link = Link.find(params[:id])
        @user = current_user
        if current_user.api_token
            save_public("yes")
            flash[:success] = "Link shared to your public feed."
            @user.get_new_links
            redirect_back_or root_url
        else
            flash[:error] = render_to_string(partial: 'add_token').html_safe
            redirect_back_or root_url
        end
    end

    def save
        @link = Link.find(params[:id])
        @user = current_user
        if current_user.api_token
            save_public("no")
            flash[:success] = "Saved link as a private bookmark."
            redirect_back_or root_url
        else
            flash[:error] = render_to_string(partial: 'add_token').html_safe
            redirect_back_or root_url
        end 
    end

    def new_comment
        @link = Link.find(params[:id])
        @comment = @link.comments.new
    end

    private
        
        def save_public(share)
            params = { auth_token: @user.api_token,
                       url: @link.url,
                       description: @link.title,
                       shared: share }.to_query

            url = "https://api.pinboard.in/v1/posts/add?#{params}"

            HTTParty.get url
        end
end
