class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      ## Database authenticatable
      t.string :email, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email
      t.string   :confirmation_code
      t.datetime :confirmation_code_generated_at
      ## User Information
      t.string :firstname
      t.string :lastname
      t.string :address
      t.date :birthday
      t.integer :gender, default: 0
      t.integer :civil_status, default: 0
      t.boolean :is_archived, default: false
      t.boolean :is_verified, default: false
      t.integer :plateform
      t.integer :order, default: 1
      t.string :type # STI

      ## Doctor-specific fields
      t.string :location
      t.string :code_user
      t.string :phone_number

      ## Patient-specific fields
      t.string :medical_history
      t.integer :plan, default: 0

      ## User Settings
      t.boolean :is_emailable, default: false
      t.boolean :is_notifiable, default: false
      t.boolean :is_smsable, default: false
      t.boolean :working_weekends, default: false

      t.uuid :doctor_id
      t.string :language, default: "fr"
      t.string :jti, default: ""
      t.timestamps
    end

    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_column :users, :account_access_granted_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
