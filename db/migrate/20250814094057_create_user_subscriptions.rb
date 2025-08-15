class CreateUserSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_subscriptions, id: :uuid do |t|
      t.uuid :doctor_id, null: false
      t.uuid :subscription_id, null: false
      t.datetime :start_date
      t.datetime :end_date
      t.string :status, default: "active"
      t.string :payment_id
      t.timestamps
    end
    add_index :user_subscriptions, [:doctor_id, :subscription_id], unique: true
  end
end
