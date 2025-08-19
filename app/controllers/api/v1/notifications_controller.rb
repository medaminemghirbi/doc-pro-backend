class Api::V1::NotificationsController < ApplicationController
  before_action :set_notification, only: [:read, :unread]

  def get_notifications
    notifications = Doctor.find(params[:id]).notifications.newest_first
    render json: notifications, each_serializer: NotificationSerializer
  end

  def read
    if @notification.unread?
      @notification.mark_as_read!
      render json: {message: "marked as read"}
    else
      render json: {message: "read already"}, status: :not_modified
    end
  end

  def unread
    if @notification.read?
      @notification.mark_as_unread!
      render json: {message: "marked as unread"}
    else
      render json: {message: "unread already"}, status: :not_modified
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
