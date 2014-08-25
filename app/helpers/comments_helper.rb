module CommentsHelper

  def delete_comment_button comment
    link_to 'Destroy Comment', [comment.post, comment],
             method: :delete,
             data: { confirm: 'Are you sure?' }
  end
end
