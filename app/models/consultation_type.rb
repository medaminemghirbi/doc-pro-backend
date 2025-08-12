class ConsultationType < ApplicationRecord
  has_many :consultations, dependent: :restrict_with_error
  validates :name, presence: true, uniqueness: true
end