class Doctor < User
  # #scopes
  scope :current, -> { where(is_archived: false) }
  scope :verified, -> { where( is_verified: true) }

  # #Includes
  include Rails.application.routes.url_helpers

  has_one_attached :avatar
  has_many :documents
  ## Callbacks

  ## Validations
  ## Associations
  has_one_attached :avatar
  has_many :consultations, dependent: :destroy
  has_many :patients, through: :consultations

  
  def patients_with_consultations
    patients
  end

  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end

  
end
