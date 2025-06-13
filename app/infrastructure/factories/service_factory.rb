module Infrastructure
  module Factories
    class ServiceFactory
      class << self
        def create_user_use_case
          Application::UseCases::Users::CreateUser.new(
            user_repository
          )
        end

        def create_booking_service
          Domain::Services::BookingService.new(
            booking_repository,
            space_repository
          )
        end

        def create_notification_service
          Infrastructure::Services::EmailNotificationService.new(
            notification_repository
          )
        end

        def create_booking_use_cases
          {
            create: Application::UseCases::Bookings::CreateBooking.new(
              create_booking_service,
              create_notification_service,
              user_repository
            ),
            cancel: Application::UseCases::Bookings::CancelBooking.new(
              create_booking_service,
              create_notification_service,
              booking_repository,
              user_repository
            ),
            list: Application::UseCases::Bookings::ListBookings.new(
              booking_repository
            ),
            confirm: Application::UseCases::Bookings::ConfirmBooking.new(
              create_booking_service,
              create_notification_service,
              booking_repository,
              user_repository
            )
          }
        end

        private

        def booking_repository
          @booking_repository ||= Infrastructure::Repositories::ActiveRecordBookingRepository.new
        end

        def space_repository
          @space_repository ||= Infrastructure::Repositories::ActiveRecordSpaceRepository.new
        end

        def user_repository
          @user_repository ||= Infrastructure::Repositories::ActiveRecordUserRepository.new
        end

        def notification_repository
          @notification_repository ||= Infrastructure::Repositories::ActiveRecordNotificationRepository.new
        end
      end
    end
  end
end
