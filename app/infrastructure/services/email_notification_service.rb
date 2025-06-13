module Infrastructure
  module Services
    class EmailNotificationService
      def initialize(logger = Rails.logger)
        @logger = logger
      end

      def send_booking_confirmation(user, booking, space)
        @logger.info("Sending booking confirmation email to #{user.email}")
        @logger.info("Booking details: Space: #{space.name}, Start: #{booking.start_time}, End: #{booking.end_time}")

        # In a real application, this would use ActionMailer to send an actual email
        # For now, we'll just log the email content
        email_content = <<~EMAIL
          Subject: Your Booking Confirmation

          Dear #{user.name},

          Your booking for #{space.name} has been confirmed.

          Booking Details:
          - Space: #{space.name}
          - Date: #{booking.start_time.to_date}
          - Time: #{booking.start_time.strftime('%H:%M')} - #{booking.end_time.strftime('%H:%M')}

          Thank you for using our Community Space Reservation System.

          Best regards,
          The Community Space Team
        EMAIL

        @logger.info("Email content: #{email_content}")

        # Return true to simulate successful email sending
        true
      end

      def send_booking_cancellation(user, booking, space)
        @logger.info("Sending booking cancellation email to #{user.email}")
        @logger.info("Booking details: Space: #{space.name}, Start: #{booking.start_time}, End: #{booking.end_time}")

        # In a real application, this would use ActionMailer to send an actual email
        email_content = <<~EMAIL
          Subject: Your Booking Cancellation

          Dear #{user.name},

          Your booking for #{space.name} has been cancelled.

          Booking Details:
          - Space: #{space.name}
          - Date: #{booking.start_time.to_date}
          - Time: #{booking.start_time.strftime('%H:%M')} - #{booking.end_time.strftime('%H:%M')}

          If you did not request this cancellation, please contact our support team.

          Thank you for using our Community Space Reservation System.

          Best regards,
          The Community Space Team
        EMAIL

        @logger.info("Email content: #{email_content}")

        # Return true to simulate successful email sending
        true
      end

      def send_booking_reminder(user, booking, space)
        @logger.info("Sending booking reminder email to #{user.email}")
        @logger.info("Booking details: Space: #{space.name}, Start: #{booking.start_time}, End: #{booking.end_time}")

        # In a real application, this would use ActionMailer to send an actual email
        email_content = <<~EMAIL
          Subject: Reminder: Your Upcoming Booking

          Dear #{user.name},

          This is a reminder about your upcoming booking:

          Booking Details:
          - Space: #{space.name}
          - Date: #{booking.start_time.to_date}
          - Time: #{booking.start_time.strftime('%H:%M')} - #{booking.end_time.strftime('%H:%M')}

          We look forward to seeing you soon!

          Best regards,
          The Community Space Team
        EMAIL

        @logger.info("Email content: #{email_content}")

        # Return true to simulate successful email sending
        true
      end

      def send_welcome_email(user)
        @logger.info("Sending welcome email to #{user.email}")

        # In a real application, this would use ActionMailer to send an actual email
        email_content = <<~EMAIL
          Subject: Welcome to the Community Space Reservation System

          Dear #{user.name},

          Welcome to the Community Space Reservation System! We're excited to have you join our community.

          With your account, you can now:
          - Browse available community spaces
          - Make reservations for your events
          - Manage your bookings

          If you have any questions, please don't hesitate to contact our support team.

          Best regards,
          The Community Space Team
        EMAIL

        @logger.info("Email content: #{email_content}")

        # Return true to simulate successful email sending
        true
      end
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/infrastructure/services/email_notification_service.rb to define EmailNotificationService
EmailNotificationService = Infrastructure::Services::EmailNotificationService
