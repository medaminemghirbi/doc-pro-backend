class Consultation < ApplicationRecord
  ## Scopes

  scope :current, -> { where(is_archived: false) }

  # after_create_commit { broadcast_notification }

  ## Includes

  ## Callbacks

  ## Validations
  validates :appointment, presence: true
  ## Associations
  belongs_to :doctor, class_name: "User", foreign_key: "doctor_id"
  belongs_to :patient, class_name: "User", foreign_key: "patient_id"
  belongs_to :consultation_type
  has_one :consultation_report, dependent: :destroy
  
  def has_report?
    consultation_report.present?
  end

  
  TIME_SLOTS = [
    {time: "09:00"},
    {time: "09:30"},
    {time: "10:00"},
    {time: "10:30"},
    {time: "11:00"},
    {time: "11:30"},
    {time: "12:00"},
    {time: "13:30"},
    {time: "14:00"},
    {time: "14:30"},
    {time: "15:00"},
    {time: "15:30"},
    {time: "16:00"}
  ]


end
