class DocumentReminderNotifier < ApplicationNotifier
  deliver_by :database

  param :document

  def message
    "Reminder: The document \"#{params[:document].title}\" is due today."
  end

  def url
    Rails.application.routes.url_helpers.document_path(params[:document])
  end
end
