class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :firstname, :lastname, :address, :birthday, :gender, 
             :civil_status, :is_archived, :order, :location,
             :code_user, :phone_number, :medical_history, 
             :is_emailable, :is_notifiable, 
             :is_smsable, :working_weekends, 
             :created_at, :updated_at, :language, :confirmation_code, 
             :confirmed_at,  :type, :account_access_granted_at,
             :confirmation_code_generated_at, :jti, :user_image_url,  :verification_pdf_url

  def user_image_url
    object.user_image_url
  end

  def type
    object.type
  end
end
