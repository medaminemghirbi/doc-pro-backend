class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.string :name, null: false
      t.decimal :price, precision: 8, scale: 2, default: 0
      t.integer :duration_in_days # null = illimité
      t.boolean :has_access_account, default: false
      t.boolean :has_access_agenda, default: false
      t.boolean :has_access_patients, default: false
      t.boolean :has_access_hr_module, default: false
      t.boolean :has_access_intelligent_prescription, default: false
      t.boolean :has_access_manage_notifications, default: false
      t.boolean :has_access_manage_documents, default: false
      t.boolean :has_access_multilang_platform, default: false
      t.boolean :has_access_ia_assistance, default: false
      t.timestamps
    end
  end
end
