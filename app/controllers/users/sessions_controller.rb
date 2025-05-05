# frozen_string_literal: true
class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # Overriding the respond_with method to return JSON instead of using flash
  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      token = JsonWebToken.encode(user_id: resource.id)
      time = Time.now + 24.hours.to_i
      Rails.cache.write("blacklist/#{token}", true, expires_in: time.to_i - Time.now.to_i)

      render json: {
        logged_in: true,
        user: UserSerializer.new(resource),
        type: resource.type,
        token: token,
        exp: time.strftime("%m-%d-%Y %H:%M")
      }
    else
      render json: { status:401 ,message: 'Login failed', errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def respond_to_on_destroy
    if current_user
      # Add token invalidation logic here if needed
      render json: { message: 'Logged out successfully.' }, status: :ok
    else
      render json: { message: 'No active session found.' }, status: :unauthorized
    end
  end
end