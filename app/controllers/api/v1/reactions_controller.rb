class ReactionsController < ApplicationController
  before_action :authorize_request
  def create
    @blog = Blog.find(params[:blog_id])
    @user = User.find_by_id params[:user_id]
    @reaction = @blog.reactions.find_or_initialize_by(user: current_user)
    
    # Set the reaction type (like or dislike)
    if params[:reaction_type] == 'like'
      @reaction.reaction_type = :like
    else
      @reaction.reaction_type = :dislike
    end

    if @reaction.save
      render json: {
        message: "Your reaction has been recorded.",
        like_count: @blog.like_count,
        dislike_count: @blog.dislike_count
      }, status: :created
    else
      render json: {
        message: "Unable to record your reaction."
      }, status: :unprocessable_entity
    end
  end

  # Remove a user's reaction from the blog post
  def destroy
    @reaction = Reaction.find(params[:id])

    # Check if the current user is the owner of the reaction
    if @reaction.user == current_user
      @reaction.destroy
      render json: {
        message: "Your reaction has been removed.",
        like_count: @reaction.blog.like_count,
        dislike_count: @reaction.blog.dislike_count
      }, status: :ok
    else
      render json: {
        message: "You are not authorized to remove this reaction."
      }, status: :forbidden
    end
  end
end
