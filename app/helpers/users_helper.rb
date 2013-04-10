module UsersHelper

    def gravatar_for(user, options = { size: 50 })
        gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
        size = options[:size]
        gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
        image_tag(gravatar_url, alt: user.name, class: "gravatar")
    end

    def post_pinboard_confirm_link(user)
            confirm_link = confirm_url( 
                type: "pinboard", 
                code: user.pinboard_confirmation_code )
            params = { auth_token: user.api_token,
                       url: confirm_link,
                       description: "Pushpin: confirm your account",

                       extended: "This is an automatically generated link used \
                       to verify your Pinboard account. It helps \
                       keep out spammers and prevents other users \
                       from impersonating you. It will disappear \
                       from your bookmarks as soon as you click through \
                       and log in to Pushpin.",

                       shared: "no" }.to_query

            url = "https://api.pinboard.in/v1/posts/add?#{params}"

            HTTParty.get url
    end

    def remove_pinboard_confirm_link(user)
            confirm_link = confirm_url( 
                type: "pinboard", 
                code: user.pinboard_confirmation_code )
            params = { auth_token: user.api_token,
                       url: confirm_link }.to_query

            url = "https://api.pinboard.in/v1/posts/delete?#{params}"

            HTTParty.get url
    end

    def get_confirm_url(args)
        confirm_url(args)
    end
end
