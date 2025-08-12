class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :message, :url, :image, :read, :type, :created_at, :updated_at

  def title
    object.event.params[:document].title

  end

  def url
    object.to_notification.url
  end

  def type
    object.to_notification.class.name
  end
end
