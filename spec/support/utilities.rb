def full_title(page_title)
  base_title = "Pushpin"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def new_user
    FactoryGirl.create(:user)
end
