class DisableAcountAccessJob < ApplicationJob
  queue_as :default

  def perform(user)
    # Vérifie que l’accès n’a pas déjà été désactivé
    if user.has_access_acount?
      # Si plus de 14 jours se sont écoulés
      if user.account_access_granted_at + 14.days <= Time.current
        user.update_column(:has_access_acount, false)
        user.user_subscriptions.first.update(status: 'locked') if user.user_subscriptions.any?
      end
    end
  end
end
