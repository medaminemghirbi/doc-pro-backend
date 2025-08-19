class User < ApplicationRecord
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  self.table_name = "users"
  enum gender: [:male, :female]
  enum plateform: [:web, :mobile]

  enum civil_status: [:Mr, :Mrs, :Mme, :other]
  # encrypts :email, deterministic: true
  # #scopes
  scope :current, -> { where(is_archived: false) }

  # Admin functionality
  def admin?
    email == 'admin@dermapro.tn' || role == 'admin'
  end

  # #Includes
  include Rails.application.routes.url_helpers
  ## Callbacks
  before_save :generate_code_user
  before_create :attach_avatar_based_on_gender
  before_validation :generate_password_for_patient, if: -> { self.type == 'Patient' && encrypted_password.blank? }
  ## Validations
  validates :email, uniqueness: true

  ## Associations
  has_one_attached :avatar, dependent: :destroy
  has_one_attached :verification_pdf
  has_many :notifications, as: :recipient, class_name: "Noticed::Notification"

  def verification_pdf_url
    verification_pdf.attached? ? url_for(verification_pdf) : nil
  end

  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end



  def send_password_reset
    generate_token(:reset_password_token)
    self.reset_password_sent_at = Time.zone.now
    save!
    UserMailer.forgot_password(self).deliver # This sends an e-mail with a link for the user to reset the password
  end

  private

  def attach_avatar_based_on_gender
    if male?
      avatar.attach(io: File.open(Rails.root.join("app", "assets", "images", "default_avatar_male.png")), filename: "default_avatar_male.png", content_type: "image/png")
    else
      avatar.attach(io: File.open(Rails.root.join("app", "assets", "images", "default_avatar_female.png")), filename: "default_avatar_female.png", content_type: "image/png")
    end
  end

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless User.exists?(column => self[column])
    end
  end

  def generate_code_user
    current_year = Time.now.year
    # Get the first two characters of the first and last name
    first_two_firstname = firstname[0, 2].capitalize
    first_two_lastname = lastname[0, 2].capitalize

    # Generate the new code
    self.code_user = "Dr-#{first_two_firstname}-#{first_two_lastname}-#{current_year}"
  end

  def generate_password_for_patient
    generated = Devise.friendly_token.first(10)  # Or SecureRandom.hex(8)
    self.password = generated
    self.password_confirmation = generated
  end

end
