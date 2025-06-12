module Domain
  module Services
    class NotificationService
      def initialize(notification_repository)
        @notification_repository = notification_repository
      end

      def create_notification(user_id, content, notification_type)
        notification = Domain::Entities::Notification.new(
          user_id: user_id,
          content: content,
          notification_type: notification_type,
          read: false
        )

        result = @notification_repository.create(notification)
        
        if result
          { success: true, notification: result, message: "Notification created successfully" }
        else
          { success: false, message: "Failed to create notification" }
        end
      end

      def mark_as_read(notification_id)
        notification = @notification_repository.find(notification_id)
        return { success: false, message: "Notification not found" } unless notification

        result = @notification_repository.mark_as_read(notification_id)
        
        if result
          { success: true, notification: result, message: "Notification marked as read" }
        else
          { success: false, message: "Failed to mark notification as read" }
        end
      end

      def get_unread_notifications(user_id)
        notifications = @notification_repository.find_unread_by_user(user_id)
        { success: true, notifications: notifications }
      end
    end
  end
end
