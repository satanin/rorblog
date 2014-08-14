class Post < ActiveRecord::Base
  mount_uploader :image, PostImageUploader
  paginates_per 5

  def timestamp
    created_at.strftime('%d %B %Y %H:%M')
  end
end
