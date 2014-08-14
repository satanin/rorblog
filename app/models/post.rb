class Post < ActiveRecord::Base
  def timestamp
    created_at.strftime('%d %B %Y %H:%M')
  end
end
