module ApplicationHelper
  def show_newpost_button
    if user_signed_in?
      link_to 'New Post',new_post_path, :class=>"btn btn-default" ,:type=>'button'
    end
  end

  def user_session_buttons
    if !user_signed_in?
      (link_to "Sign in", new_user_session_path, :class=>'btn btn-default navbar-btn') +
      (link_to "Sign up", new_user_registration_path, :class=>'btn btn-default navbar-btn') 
    else
      (link_to "Sign out", destroy_user_session_path, method: :delete, :class=>'btn btn-primary navbar-btn') +
      (link_to "Edit Profile", edit_user_registration_path, :class=>'btn btn-default navbar-btn')
    end
  end

  def user_details
    result = (' ')
    if user_signed_in?
      result +=('- Hello ' + current_user.name) + (' ') + (image_tag current_user.avatar , :class=>"user-header-avatar")
    end
    result
  end

  def post_navigation_buttons
    result = (link_to 'Edit', edit_post_path(@post), :class=>"btn btn-info" ,:type=>'button')
    result += (link_to 'Back', posts_path, :class=>"btn btn-default" ,:type=>'button')
    if owner?
      result += (link_to 'Delete', post_path(@post), method: :delete, data: { confirm: 'Are you sure?' }, :class=>"btn btn-default" ,:type=>'button')
    end
    result
  end


  def owner?
    @post.user_id == current_user.id
  end
end
