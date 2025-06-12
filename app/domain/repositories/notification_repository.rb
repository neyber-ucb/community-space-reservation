module Domain
  module Repositories
    class NotificationRepository
      def find(id)
        raise NotImplementedError
      end

      def all
        raise NotImplementedError
      end

      def find_by_user(user_id)
        raise NotImplementedError
      end

      def find_unread_by_user(user_id)
        raise NotImplementedError
      end

      def create(notification)
        raise NotImplementedError
      end

      def update(notification)
        raise NotImplementedError
      end

      def mark_as_read(id)
        raise NotImplementedError
      end

      def delete(id)
        raise NotImplementedError
      end
    end
  end
end
