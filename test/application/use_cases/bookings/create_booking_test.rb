require "test_helper"
require_relative "../../../../app/application/use_cases/bookings/create_booking"
require_relative "../../../../app/domain/entities/booking"

module Application
  module UseCases
    module Bookings
      class CreateBookingTest < ActiveSupport::TestCase
        def setup
          @booking_service = Minitest::Mock.new
          @notification_service = Minitest::Mock.new
          @user_repository = Minitest::Mock.new
          @email_notification_service = Minitest::Mock.new

          @use_case = CreateBooking.new(
            @booking_service,
            @notification_service,
            @user_repository,
            @email_notification_service
          )

          # Sample booking parameters
          @user_id = 2
          @space_id = 3
          @start_time = Time.now + 1.day
          @end_time = Time.now + 1.day + 2.hours

          # Sample created booking
          @created_booking = Domain::Entities::Booking.new(
            id: 1,
            user_id: @user_id,
            space_id: @space_id,
            start_time: @start_time,
            end_time: @end_time,
            status: "pending",
            created_at: Time.now,
            updated_at: Time.now
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

        test "creates booking successfully" do
          # Mock booking service to create the booking with named parameters
          @booking_service.expect(:create_booking, { success: true, booking: @created_booking }) do |user_id:, space_id:, start_time:, end_time:|
            assert_equal @user_id, user_id
            assert_equal @space_id, space_id
            assert_equal @start_time, start_time
            assert_equal @end_time, end_time
            true
          end

          # Mock user repository to return the user
          @user_repository.expect :find, @user, [ @user_id ]

          # Mock notification service to create a notification
          expected_notification = "Your booking for space #{@space_id} from #{@start_time} to #{@end_time} has been created and is pending confirmation."
          @notification_service.expect :create_notification, true, [ @user_id, expected_notification, "system" ]

          # Mock email notification service to send an email
          @email_notification_service.expect :send_email, true, [ @user.email, "Booking Confirmation", expected_notification ]

          # Execute the use case
          result = @use_case.execute(
            user_id: @user_id,
            space_id: @space_id,
            start_time: @start_time,
            end_time: @end_time
          )

          # Verify the result
          assert result[:success]
          assert_equal @created_booking, result[:booking]

          # Verify all mocks
          @booking_service.verify
          @user_repository.verify
          @notification_service.verify
          @email_notification_service.verify
        end

        test "handles booking service failure" do
          # Mock booking service to fail creation with named parameters
          error_message = "Space is not available for the requested time"
          @booking_service.expect(:create_booking, { success: false, message: error_message }) do |user_id:, space_id:, start_time:, end_time:|
            assert_equal @user_id, user_id
            assert_equal @space_id, space_id
            assert_equal @start_time, start_time
            assert_equal @end_time, end_time
            true
          end

          # Execute the use case
          result = @use_case.execute(
            user_id: @user_id,
            space_id: @space_id,
            start_time: @start_time,
            end_time: @end_time
          )

          # Verify the result
          assert_not result[:success]
          assert_equal error_message, result[:message]

          # Verify mock expectations
          @booking_service.verify
        end

        test "handles user not found" do
          # Mock booking service to create the booking with named parameters
          @booking_service.expect(:create_booking, { success: true, booking: @created_booking }) do |user_id:, space_id:, start_time:, end_time:|
            assert_equal @user_id, user_id
            assert_equal @space_id, space_id
            assert_equal @start_time, start_time
            assert_equal @end_time, end_time
            true
          end

          # Mock user repository to return nil (user not found)
          @user_repository.expect :find, nil, [ @user_id ]

          # Execute the use case
          result = @use_case.execute(
            user_id: @user_id,
            space_id: @space_id,
            start_time: @start_time,
            end_time: @end_time
          )

          # Verify the result is still successful even though notification couldn't be sent
          assert result[:success]
          assert_equal @created_booking, result[:booking]

          # Verify mock expectations
          @booking_service.verify
          @user_repository.verify
        end
      end
    end
  end
end
