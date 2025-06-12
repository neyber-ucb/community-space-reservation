module Application
  module UseCases
    module Bookings
      class ListBookings
        def initialize(booking_repository, space_repository)
          @booking_repository = booking_repository
          @space_repository = space_repository
        end

        def execute(filters = {})
          if filters[:user_id]
            bookings = @booking_repository.find_by_user(filters[:user_id])
          elsif filters[:space_id]
            bookings = @booking_repository.find_by_space(filters[:space_id])
          elsif filters[:start_date] && filters[:end_date]
            bookings = @booking_repository.find_by_date_range(filters[:start_date], filters[:end_date])
          else
            bookings = @booking_repository.all
          end

          # Optionally enrich bookings with space information
          if filters[:include_space_details] && !bookings.empty?
            bookings = bookings.map do |booking|
              space = @space_repository.find(booking.space_id)
              { booking: booking, space: space }
            end
          end

          { success: true, bookings: bookings }
        end
      end
    end
  end
end
