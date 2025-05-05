class Api::Mobile::UsersController < ApplicationController
    def update_settings
        @user = User.find(params[:id])
        if @user.update(params_informations_user)
          render json: @user, methods: [:user_image_url]
        else
          render json: @user.errors, statut: :unprocessable_entity
        end
    end

    private
    def params_informations_user
        permitted_params = params.require(:user).permit(:id,  :is_emailable,  :is_notifiable, :is_smsable)
        permitted_params
    end
end