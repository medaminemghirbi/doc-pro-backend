class Consultation < ApplicationRecord
  # Scopes
  scope :current, -> { where(is_archived: false) }
  scope :upcoming, -> { where('appointment > ?', Time.current) }
  scope :past, -> { where('appointment < ?', Time.current) }
  scope :today, -> { where(appointment: Date.current.beginning_of_day..Date.current.end_of_day) }
  
  # Enums
  enum status: { pending: 0, confirmed: 1, cancelled: 2, completed: 3, no_show: 4 }
  enum consultation_type: { initial: 0, follow_up: 1, emergency: 2, routine_checkup: 3 }
  enum payment_status: { unpaid: 0, paid: 1, partial: 2 }
  
  # Validations
  validates :appointment, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validate :appointment_in_future, on: :create
  validate :appointment_during_working_hours
  validate :no_overlapping_consultations
  
  # Associations
  belongs_to :doctor, class_name: "Doctor", foreign_key: "doctor_id"
  belongs_to :patient, class_name: "Patient", foreign_key: "patient_id"
  has_one :consultation_report, dependent: :destroy
  has_many_attached :medical_images
  
  # Callbacks
  before_validation :set_default_duration, if: -> { duration_minutes.blank? }
  
  # Methods
  def end_time
    return nil unless appointment && duration_minutes
    appointment + duration_minutes.minutes
  end

  def can_be_cancelled?
    pending? && appointment > 24.hours.from_now
  end

  def can_be_rescheduled?
    (pending? || confirmed?) && appointment > 24.hours.from_now
  end

  def has_report?
    consultation_report.present?
  end

  def formatted_appointment
    return '' unless appointment
    appointment.strftime('%B %d, %Y at %I:%M %p')
  end

  def consultation_duration
    return 'Not specified' unless duration_minutes
    
    hours = duration_minutes / 60
    minutes = duration_minutes % 60
    
    if hours > 0 && minutes > 0
      "#{hours}h #{minutes}min"
    elsif hours > 0
      "#{hours}h"
    else
      "#{minutes}min"
    end
  end

  def medical_images_urls
    medical_images.attached? ? medical_images.map { |img| Rails.application.routes.url_helpers.url_for(img) } : []
  end
  
  private
  
  def appointment_in_future
    return unless appointment
    
    errors.add(:appointment, "must be in the future") if appointment <= Time.current
  end

  def appointment_during_working_hours
    return unless appointment
    
    hour = appointment.hour
    day_of_week = appointment.wday
    
    # Assuming working hours: Monday-Friday 8:00-18:00, Saturday 8:00-14:00
    if day_of_week == 0 # Sunday
      errors.add(:appointment, "cannot be scheduled on Sunday")
    elsif day_of_week == 6 # Saturday
      errors.add(:appointment, "Saturday hours are 8:00 AM - 2:00 PM") if hour < 8 || hour >= 14
    else # Monday-Friday
      errors.add(:appointment, "Working hours are 8:00 AM - 6:00 PM") if hour < 8 || hour >= 18
    end
  end

  def set_default_duration
    self.duration_minutes = case consultation_type
                           when 'initial' then 60
                           when 'follow_up' then 30
                           when 'emergency' then 45
                           when 'routine_checkup' then 30
                           else 30
                           end
  end
  
  def no_overlapping_consultations
    return unless appointment && duration_minutes && doctor_id
    
    consultation_end = appointment + duration_minutes.minutes
    
    overlapping = Consultation.where(doctor_id: doctor_id)
                             .where.not(id: id)
                             .where.not(status: [:cancelled, :no_show])
                             .where(
                               "(appointment <= ? AND (appointment + INTERVAL duration_minutes MINUTE) > ?) OR " \
                               "(appointment < ? AND (appointment + INTERVAL duration_minutes MINUTE) >= ?) OR " \
                               "(appointment >= ? AND (appointment + INTERVAL duration_minutes MINUTE) <= ?)",
                               appointment, appointment, consultation_end, consultation_end, appointment, consultation_end
                             )
    
    errors.add(:appointment, "conflicts with an existing consultation") if overlapping.exists?
  end
end
