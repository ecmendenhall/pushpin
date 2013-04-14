module ApplicationHelper

    @@markdown_engine = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                               autolink: true,
                                               space_after_headers: true,
                                               fenced_code_blocks: true,
                                               strikethrough: true)

    def full_title(page_title)
        base_title = "Pushpin"
        if page_title.empty?
            base_title
        else
            "#{base_title} | #{page_title}"
        end
    end

    def markdown(text)
      @@markdown_engine.render(text).html_safe
    end
    
end
