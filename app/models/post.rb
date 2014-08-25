class Post < ActiveRecord::Base
  mount_uploader :image, PostImageUploader
  paginates_per 5
  has_many :comments, dependent: :destroy
  belongs_to :user

  def timestamp
    created_at.strftime('%B %d %Y, %H:%M')
  end
end
