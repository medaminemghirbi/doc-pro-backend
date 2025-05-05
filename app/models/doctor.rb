class Doctor < User
  # #scopes
  scope :current, -> { where(is_archived: false) }
  # #Includes
  include Rails.application.routes.url_helpers
  enum plan: {no_plan: 0, basic: 1, premium: 2, custom: 3}

  has_one_attached :avatar
  has_one :doctor_usage
  has_many :documents

  geocoded_by :address
  ## Callbacks

  ## Validations
  after_validation :geocode, if: ->(obj) { obj.address.present? and obj.address_changed? }
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode

  ## Associations
  has_one_attached :avatar
  has_many :blogs, dependent: :destroy
  has_many :consultations, dependent: :destroy
  has_many :patients, through: :consultations
  has_many :phone_numbers, dependent: :destroy
  has_many :custom_mails
  has_many :ratings, through: :consultations

  has_many :doctor_services, dependent: :destroy
  has_many :services, through: :doctor_services

  def patients_with_consultations
    patients
  end

  def limit_callback
    case plan
    when "no_plan"
      0
    when "basic"
      30
    when "premium"
      Float::INFINITY
    when "custom"
      custom_limit
    else
      0
    end
  end

  def remaining_tries
    current_usage = doctor_usage&.count || 0
    case plan
    when "no_plan"
      0
    when "basic"
      [30 - current_usage, 0].max
    when "premium"
      Float::INFINITY # Premium has unlimited tries
    when "custom"
      [custom_limit - current_usage, 0].max
    else
      0
    end
  end

  def display_remaining_tries
    case plan
    when "premium"
      "Nombre d'essais illimité" # Unlimited tries for premium
    when "custom"
      "Essais restants : #{remaining_tries}" # Custom limit with remaining tries
    when "basic"
      "Essais restants : #{remaining_tries}" # Remaining tries for basic plan
    else
      "Pas d'essais disponibles"
    end
  end

  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end

  def first_number
    phone_numbers.first&.number
  end

  def user_image_url_mobile
    return nil unless avatar.attached?
    image_url = Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: false)
    host = AppConfig.find_by(key: "mobile")&.value || "localhost:3000"
    image_url.gsub("localhost:3000", host)
  end

  def finished_consultations_count
    consultations.finished.count
  end
end
