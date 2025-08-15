class UserSubscription < ApplicationRecord
  belongs_to :doctor
  belongs_to :subscription
end