class UpdateConsultationStatusJob < ApplicationJob
  queue_as :default

  def perform
    Consultation.approved.where("appointment < ?", 12.hours.ago).find_each do |consultation|
      consultation.update!(status: :finished)
    end
  end
end
