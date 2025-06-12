module Application
  module UseCases
    module Bookings
      class CreateBooking
        def initialize(booking_service, notification_service, user_repository, email_notification_service = nil)
          @booking_service = booking_service
          @notification_service = notification_service
          @user_repository = user_repository
          @email_notification_service = email_notification_service
        end

        def execute(user_id:, space_id:, start_time:, end_time:)
          # Create the booking
          result = @booking_service.create_booking(
            user_id: user_id,
            space_id: space_id,
            start_time: start_time,
            end_time: end_time
          )
          
          if result[:success]
            # Send notification to user
            user = @user_repository.find(user_id)
            if user
              notification_content = "Your booking for space #{space_id} from #{start_time} to #{end_time} has been created and is pending confirmation."
              @notification_service.create_notification(user_id, notification_content, 'system')
              
              # Send email notification if service is available
              if @email_notification_service && @email_notification_service.respond_to?(:send_email)
                @email_notification_service.send_email(
                  user.email,
                  "Booking Confirmation",
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
