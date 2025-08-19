class Payment < ApplicationRecord
  belongs_to :doctor, class_name: "Doctor", foreign_key: "doctor_id"
  enum status: {pending: 0, approved: 1, failed: 2}
end