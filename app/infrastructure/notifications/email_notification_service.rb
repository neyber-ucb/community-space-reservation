module Infrastructure
  module Notifications
    class EmailNotificationService
      def initialize
        # In a real application, this would be configured with an email service
      end

      def send_notification(user, subject, content)
        # In a real application, this would send an actual email
        # For development purposes, we'll use Rails' logger
        Rails.logger.info "Sending email to #{user.email}"
        Rails.logger.info "Subject: #{subject}"
        Rails.logger.info "Content: #{content}"

        # Mock successful email delivery
        true
      end

      def send_booking_confirmation(user, booking, space)
        subject = "Booking Confirmation: #{space.name}"
        content = <<~CONTENT
          Hello #{user.name},

          Your booking for #{space.name} has been confirmed.

          Details:
          - Date: #{booking.start_time.strftime('%B %d, %Y')}
          - Time: #{booking.start_time.strftime('%I:%M %p')} to #{booking.end_time.strftime('%I:%M %p')}
          - Space: #{space.name}
          - Space Type: #{space.space_type}

          Thank you for using our service!
        CONTENT

        send_notification(user, subject, content)
      end

      def send_booking_cancellation(user, booking, space)
        subject = "Booking Cancellation: #{space.name}"
        content = <<~CONTENT
          Hello #{user.name},

          Your booking for #{space.name} has been cancelled.

          Details:
          - Date: #{booking.start_time.strftime('%B %d, %Y')}
          - Time: #{booking.start_time.strftime('%I:%M %p')} to #{booking.end_time.strftime('%I:%M %p')}
          - Space: #{space.name}
          - Space Type: #{space.space_type}

          If you did not request this cancellation, please contact us.
        CONTENT

        send_notification(user, subject, content)
      end
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/infrastructure/notifications/email_notification_service.rb to define EmailNotificationService
EmailNotificationService = Infrastructure::Notifications::EmailNotificationService
