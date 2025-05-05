class User < ApplicationRecord
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::JTIMatcher
  self.table_name = "users"
  enum gender: [:male, :female]
  enum plateform: [:web, :mobile]

  enum civil_status: [:Mr, :Mrs, :Mme, :other]
  # encrypts :email, deterministic: true
  # #scopes
  scope :current, -> { where(is_archived: false) }

  # #Includes
  include Rails.application.routes.url_helpers
  include Devise::JWT::RevocationStrategies::JTIMatcher
  ## Callbacks
  before_save :generate_code_doc
  before_create :attach_avatar_based_on_gender
  before_create :set_jti
  ## Validations
  validates :email, uniqueness: true

  ## Associations
  has_one_attached :avatar, dependent: :destroy

  has_many :phone_numbers, dependent: :destroy
  has_many :sent_messages, class_name: "Message"
  has_many :received_messages, class_name: "Message"

  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end

  def user_image_url_mobile
    # Get the URL of the associated image
    image_url = Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: false)
    host = AppConfig.find_by(key: "mobile")&.value || "localhost:3000"
    image_url.gsub("localhost:3000", host)
  end

  def validate_confirmation_code(code)
    if confirmation_code == code
      update(confirmed_at: Time.now, confirmation_code: nil, confirmation_code_generated_at: nil)
      true
    else
      false
    end
  end

  def confirmation_code_expired?
    confirmation_code_generated_at.nil? || (Time.current > (confirmation_code_generated_at + 5.minute))
  end

  def send_password_reset
    generate_token(:reset_password_token)
    self.reset_password_sent_at = Time.zone.now
    save!
    UserMailer.forgot_password(self).deliver # This sends an e-mail with a link for the user to reset the password
  end

  private

  def set_jti
    self.jti ||= SecureRandom.uuid
  end

  def attach_avatar_based_on_gender
    if male?
      avatar.attach(io: File.open(Rails.root.join("app", "assets", "images", "default_avatar.png")), filename: "default_avatar.png", content_type: "image/png")
    else
      avatar.attach(io: File.open(Rails.root.join("app", "assets", "images", "default_female_avatar.png")), filename: "default_female_avatar.png", content_type: "image/png")
    end
  end



  # This generates a random password reset token for the user
  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless User.exists?(column => self[column])
    end
  end

  def generate_code_doc
    return unless type == "Doctor"
    current_year = Time.now.year
    # Get the first two characters of the first and last name
    first_two_firstname = firstname[0, 2].capitalize
    first_two_lastname = lastname[0, 2].capitalize

    # Generate the new code
    self.code_doc = "Dr-#{first_two_firstname}-#{first_two_lastname}-#{current_year}"
  end
end
