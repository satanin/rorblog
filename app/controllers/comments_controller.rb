class CommentsController < ApplicationController
  before_action :identify_current_post, only: [:create, :destroy]

   def create
    @comment = @post.comments.create(comment_params)
    redirect_to_post
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to_post
  end

  private
  def identify_current_post
    @post = Post.find(params[:post_id])
  end

  def redirect_to_post
    redirect_to post_path(@post)
  end

  def comment_params
    params.require(:comment).permit(:commenter, :body)
  end
end
