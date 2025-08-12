class DocumentReminderJob < ApplicationJob
  queue_as :default

  def perform
    today = Time.zone.today
    due_documents = Document.where(remind_date: today)

    due_documents.each do |doc|
      next if doc.notified_at.present?

      # Send notification using Noticed
      DocumentReminderNotifier.with(document: doc).deliver_later(doc.doctor)
      doc.update_column(:notified_at, Time.zone.now)
      ActionCable.server.broadcast "DocumentChannel#{doc.doctor.id}", {
        message: "Reminder: Document \"#{doc.title}\" is due today.",
        status: "reminder",
        subject: "document_due"
      }
    end
  end
end
