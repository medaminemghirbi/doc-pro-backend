class AddAccessPermissionsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :has_access_acount,           :boolean, default: true
    add_column :users, :has_access_agenda,           :boolean, default: true
    add_column :users, :has_access_patients,         :boolean, default: true

    add_column :users, :has_access_hr_module,                :boolean, default: false
    add_column :users, :has_access_intelligent_prescrip,     :boolean, default: false
    add_column :users, :has_access_manage_notifications,     :boolean, default: false
    add_column :users, :has_access_manage_documents,         :boolean, default: false
    add_column :users, :has_access_multilang_platform,       :boolean, default: false

    # Champ pour suivre quand l'accès a été accordé
    add_column :users, :acount_access_granted_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }

  end
end
