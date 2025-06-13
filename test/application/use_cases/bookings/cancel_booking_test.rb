require "test_helper"
require_relative "../../../../app/application/use_cases/bookings/cancel_booking"
require_relative "../../../../app/domain/entities/booking"

module Application
  module UseCases
    module Bookings
      class CancelBookingTest < ActiveSupport::TestCase
        def setup
          @booking_service = Minitest::Mock.new
          @notification_service = Minitest::Mock.new
          @user_repository = Minitest::Mock.new
          @booking_repository = Minitest::Mock.new
          @email_notification_service = Minitest::Mock.new

          @use_case = CancelBooking.new(
            @booking_service,
            @notification_service,
            @user_repository,
            @booking_repository,
            @email_notification_service
          )

          # Sample booking
          @booking = Domain::Entities::Booking.new(
            id: 1,
            user_id: 2,
            space_id: 3,
            start_time: Time.now + 1.day,
            end_time: Time.now + 1.day + 2.hours,
            status: "confirmed",
            created_at: Time.now - 1.day,
            updated_at: Time.now - 1.day
          )

          # Sample user
          @user = Domain::Entities::User.new(
            id: 2,
            name: "John Doe",
            email: "john@example.com",
            password_digest: "hashed_password",
            role: "user"
          )
        end

        test "cancels booking successfully" do
          # Mock booking repository to return the booking
          @booking_repository.expect :find, @booking, [ 1 ]

          # Mock booking service to cancel the booking
          @booking_service.expect :cancel_booking, { success: true, booking: @booking }, [ @booking ]

          # Mock user repository to return the user
          @user_repository.expect :find, @user, [ 2 ]

          # Mock notification service to create a notification
          @notification_service.expect :create_notification, true, [ 2, "Your booking (ID: 1) has been cancelled.", "system" ]

          # Mock email notification service to send an email
          @email_notification_service.expect :send_email, true, [ @user.email, "Booking Cancellation", "Your booking (ID: 1) has been cancelled." ]

          # Execute the use case
          result = @use_case.execute(booking_id: 1)

          # Verify the result
          assert result[:success]
          assert_equal @booking, result[:booking]

          # Verify all mocks
          @booking_repository.verify
          @booking_service.verify
          @user_repository.verify
          @notification_service.verify
          @email_notification_service.verify
        end

        test "fails when booking is not found" do
          # Mock booking repository to return nil (booking not found)
          @booking_repository.expect :find, nil, [ 999 ]

          # Execute the use case
          result = @use_case.execute(booking_id: 999)

          # Verify the result
          assert_not result[:success]
          assert_equal "Booking not found", result[:message]

          # Verify mock expectations
          @booking_repository.verify
        end

        test "handles booking service failure" do
          # Mock booking repository to return the booking
          @booking_repository.expect :find, @booking, [ 1 ]

          # Mock booking service to fail cancellation
          @booking_service.expect :cancel_booking, { success: false, message: "Cannot cancel booking" }, [ @booking ]

          # Execute the use case
          result = @use_case.execute(booking_id: 1)

          # Verify the result
          assert_not result[:success]
          assert_equal "Cannot cancel booking", result[:message]

          # Verify mock expectations
          @booking_repository.verify
          @booking_service.verify
        end
      end
    end
  end
end
