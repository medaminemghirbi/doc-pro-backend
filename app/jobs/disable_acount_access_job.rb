class DisableAcountAccessJob < ApplicationJob
  queue_as :default

  def perform(user)
    # Vérifie que l’accès n’a pas déjà été désactivé
    if user.has_access_acount? && user.acount_access_granted_at.present?
      # Si plus de 14 jours se sont écoulés
      if user.acount_access_granted_at + 14.days <= Time.current
        user.update_column(:has_access_acount, false) # bypass callbacks
      end
    end
  end
end
