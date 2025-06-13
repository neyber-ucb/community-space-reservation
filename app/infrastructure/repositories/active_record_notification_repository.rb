module Infrastructure
  module Repositories
    class ActiveRecordNotificationRepository < Domain::Repositories::NotificationRepository
      def find(id)
        notification_record = Notification.find_by(id: id)
        return nil unless notification_record

        map_to_entity(notification_record)
      end

      def all
        Notification.all.map { |notification_record| map_to_entity(notification_record) }
      end

      def find_by_user(user_id)
        Notification.where(user_id: user_id).map { |notification_record| map_to_entity(notification_record) }
      end

      def find_unread_by_user(user_id)
        Notification.where(user_id: user_id, read: false).map { |notification_record| map_to_entity(notification_record) }
      end

      def create(notification)
        notification_record = Notification.new(
          user_id: notification.user_id,
          content: notification.content,
          notification_type: notification.notification_type,
          read: notification.read
        )

        return nil unless notification_record.save

        map_to_entity(notification_record)
      end

      def update(notification)
        notification_record = Notification.find_by(id: notification.id)
        return nil unless notification_record

        notification_record.content = notification.content if notification.content
        notification_record.notification_type = notification.notification_type if notification.notification_type
        notification_record.read = notification.read if !notification.read.nil?

        return nil unless notification_record.save

        map_to_entity(notification_record)
      end

      def mark_as_read(id)
        notification_record = Notification.find_by(id: id)
        return nil unless notification_record

        notification_record.read = true
        return nil unless notification_record.save

        map_to_entity(notification_record)
      end

      def delete(id)
        notification_record = Notification.find_by(id: id)
        return false unless notification_record

        notification_record.destroy
        true
      end

      private

      def map_to_entity(notification_record)
        Domain::Entities::Notification.new(
          id: notification_record.id,
          user_id: notification_record.user_id,
          content: notification_record.content,
          notification_type: notification_record.notification_type,
          read: notification_record.read,
          created_at: notification_record.created_at,
          updated_at: notification_record.updated_at
        )
      end
    end
  end
end
