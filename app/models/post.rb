class Post < ActiveRecord::Base
  mount_uploader :image, PostImageUploader
  def timestamp
    created_at.strftime('%d %B %Y %H:%M')
  end
end
