class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments, id: :uuid do |t|

      t.uuid "user_subscription_id", null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :payment_method, null: false # e.g., 'credit_card', 'paypal'
      t.integer :status, default: 0 # 0 = completed, 1 = failed, 2 = pending
      t.datetime :paid_at
      t.timestamps
    end
  end
end
