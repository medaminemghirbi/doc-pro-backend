class Doctor < User
  # #scopes
  scope :current, -> { where(is_archived: false) }
  scope :verified, -> { where( is_verified: true) }

  # #Includes
  include Rails.application.routes.url_helpers

  has_one_attached :avatar
  has_many :documents

  ## Callbacks
  after_create :assign_default_subscription
  ## Validations
  ## Associations
  has_one_attached :avatar
  has_many :consultations, dependent: :destroy
  has_many :patients, through: :consultations

  has_many :user_subscriptions
  has_many :subscriptions, through: :user_subscriptions
  after_create :schedule_disable_acount_access

  def patients_with_consultations
    patients
  end

  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end
  
  def assign_default_subscription
    trial_subscription = Subscription.find_by(name: "trial")
    return unless trial_subscription

    # Prevent duplicate trial subscription
    unless user_subscriptions.exists?(subscription_id: trial_subscription.id)
      user_subscriptions.create!(subscription: trial_subscription, start_date: Time.zone.now, status: "active")
    end
  end


  def schedule_disable_acount_access
    DisableAcountAccessJob.set(wait: 14.days).perform_later(self)
  end

end
