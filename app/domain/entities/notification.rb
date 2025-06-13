module Domain
  module Entities
    class Notification
      attr_reader :id, :user_id, :content, :notification_type, :read, :created_at, :updated_at

      def initialize(attributes = {})
        @id = attributes[:id]
        @user_id = attributes[:user_id]
        @content = attributes[:content]
        @notification_type = attributes[:notification_type]
        @read = attributes[:read] || false
        @created_at = attributes[:created_at]
        @updated_at = attributes[:updated_at]
      end

      def mark_as_read
        @read = true
      end
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/domain/entities/notification.rb to define Notification
Notification = Domain::Entities::Notification
