module Interfaces
  module Controllers
    module Api
      module V1
        class BookingsController < ApplicationController
          before_action :authorize_admin, only: [ :confirm, :cancel, :index_admin ]

          # GET /api/v1/bookings
          def index
            list_bookings = Application::UseCases::Bookings::ListBookings.new(booking_repository, space_repository)
            result = list_bookings.execute(
              user_id: current_user.id,
              include_space_details: true
            )

            render json: { bookings: result[:bookings] }
          end

          # GET /api/v1/admin/bookings
          def index_admin
            filters = {}
            filters[:space_id] = params[:space_id] if params[:space_id].present?
            filters[:start_date] = params[:start_date] if params[:start_date].present?
            filters[:end_date] = params[:end_date] if params[:end_date].present?
            filters[:include_space_details] = true

            list_bookings = Application::UseCases::Bookings::ListBookings.new(booking_repository, space_repository)
            result = list_bookings.execute(filters)

            render json: { bookings: result[:bookings] }
          end

          # GET /api/v1/bookings/:id
          def show
            booking = booking_repository.find(params[:id])

            if booking && (booking.user_id == current_user.id || current_user.admin?)
              space = space_repository.find(booking.space_id)
              render json: { booking: booking_to_json(booking), space: space_to_json(space) }
            else
              render json: { error: "Booking not found or unauthorized" }, status: :not_found
            end
          end

          # POST /api/v1/bookings
          def create
            create_booking = Application::UseCases::Bookings::CreateBooking.new(
              booking_service,
              notification_service,
              user_repository
            )

            result = create_booking.execute(
              user_id: current_user.id,
              space_id: booking_params[:space_id],
              start_time: Time.parse(booking_params[:start_time]),
              end_time: Time.parse(booking_params[:end_time])
            )

            if result[:success]
              render json: {
                message: result[:message],
                booking: booking_to_json(result[:booking])
              }, status: :created
            else
              render json: { error: result[:message] }, status: :unprocessable_entity
            end
          end

          # POST /api/v1/bookings/:id/confirm
          def confirm
            confirm_booking = Application::UseCases::Bookings::ConfirmBooking.new(
              booking_service,
              notification_service,
              user_repository,
              booking_repository
            )

            result = confirm_booking.execute(booking_id: params[:id])

            if result[:success]
              render json: { message: result[:message], booking: booking_to_json(result[:booking]) }
            else
              render json: { error: result[:message] }, status: :unprocessable_entity
            end
          end

          # POST /api/v1/bookings/:id/cancel
          def cancel
            cancel_booking = Application::UseCases::Bookings::CancelBooking.new(
              booking_service,
              notification_service,
              user_repository,
              booking_repository
            )

            result = cancel_booking.execute(booking_id: params[:id])

            if result[:success]
              render json: { message: result[:message], booking: booking_to_json(result[:booking]) }
            else
              render json: { error: result[:message] }, status: :unprocessable_entity
            end
          end

          private

          def booking_params
            params.require(:booking).permit(:space_id, :start_time, :end_time)
          end

          def booking_repository
            @booking_repository ||= Infrastructure::Repositories::ActiveRecordBookingRepository.new
          end

          def space_repository
            @space_repository ||= Infrastructure::Repositories::ActiveRecordSpaceRepository.new
          end

          def user_repository
            @user_repository ||= Infrastructure::Repositories::ActiveRecordUserRepository.new
          end

          def notification_service
            @notification_service ||= Domain::Services::NotificationService.new(
              Infrastructure::Repositories::ActiveRecordNotificationRepository.new
            )
          end

          def booking_service
            @booking_service ||= Domain::Services::BookingService.new(
              booking_repository,
              space_repository
            )
          end

          def booking_to_json(booking)
            {
              id: booking.id,
              user_id: booking.user_id,
              space_id: booking.space_id,
              start_time: booking.start_time,
              end_time: booking.end_time,
              status: booking.status,
              created_at: booking.created_at,
              updated_at: booking.updated_at
            }
          end

          def space_to_json(space)
            {
              id: space.id,
              name: space.name,
              description: space.description,
              capacity: space.capacity,
              space_type: space.space_type,
              created_at: space.created_at,
              updated_at: space.updated_at
            }
          end

          def authorize_admin
            render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.admin?
          end
        end
      end
    end
  end
end
