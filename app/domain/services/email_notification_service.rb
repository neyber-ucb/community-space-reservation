# frozen_string_literal: true

module Domain
  module Services
    # This is a domain service interface for email notifications
    # It delegates to the infrastructure implementation
    class EmailNotificationService
      # Initialize with the infrastructure implementation
      def initialize
        @implementation = Infrastructure::Services::EmailNotificationService.new
      end

      # Delegate all methods to the infrastructure implementation
      def method_missing(method_name, *args, &block)
        if @implementation.respond_to?(method_name)
          @implementation.send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @implementation.respond_to?(method_name, include_private) || super
      end
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/domain/services/email_notification_service.rb to define EmailNotificationService
EmailNotificationService = Domain::Services::EmailNotificationService
