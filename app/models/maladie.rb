class Maladie < ApplicationRecord
  ##scopes
  scope :current, -> { where(is_archived: false) }
  ##Includes
  include Rails.application.routes.url_helpers

  ## Callbacks

  ## Validations
  validates :maladie_name, presence: true, uniqueness: true

  ## Associations
  has_one_attached :image
  has_many :blogs
  def diseas_image_url
    # Get the URL of the associated image
    image.attached? ? url_for(image) : nil
  end

  private

end