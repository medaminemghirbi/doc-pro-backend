class Api::Mobile::UsersController < ApplicationController
    def update_settings
        @user = User.find(params[:id])
        if @user.update(params_informations_user)
          render json: @user, methods: [:user_image_url_mobile]
        else
          render json: @user.errors, statut: :unprocessable_entity
        end
    end

    private
    def params_image_user
      params.permit(:id, :avatar)
    end

    def params_informations_user
      permitted_params = params.permit(:id, :birthday, :lastname, :firstname, :location,
                                       :is_emailable,  :is_notifiable, :is_smsable, :phone_number, :language, :avatar, :password, :password_confirmation)
      permitted_params
    end
end