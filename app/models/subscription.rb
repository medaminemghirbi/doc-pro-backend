class Subscription < ApplicationRecord

    has_many :user_subscriptions
    has_many :users, through: :user_subscriptions
    enum status: { active: 0, locked: 1 }

end
