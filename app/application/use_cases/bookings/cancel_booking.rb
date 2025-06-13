module Application
  module UseCases
    module Bookings
      class CancelBooking
        def initialize(booking_service, notification_service, user_repository, booking_repository, email_notification_service = nil)
          @booking_service = booking_service
          @notification_service = notification_service
          @user_repository = user_repository
          @booking_repository = booking_repository
          @email_notification_service = email_notification_service
        end

        def execute(booking_id:)
          # Get the booking first to find the user
          booking = @booking_repository.find(booking_id)
          return { success: false, message: "Booking not found" } unless booking

          # Cancel the booking
          result = @booking_service.cancel_booking(booking)

          if result[:success]
            # Send notification to user
            user = @user_repository.find(booking.user_id)
            if user
              notification_content = "Your booking (ID: #{booking_id}) has been cancelled."
              @notification_service.create_notification(booking.user_id, notification_content, "system")

              # Send email notification if service is available
              if @email_notification_service && @email_notification_service.respond_to?(:send_email)
                @email_notification_service.send_email(
                  user.email,
                  "Booking Cancellation",
                  notification_content
                )
              end
            end
          end

          result
        end
      end
    end
  end
end
