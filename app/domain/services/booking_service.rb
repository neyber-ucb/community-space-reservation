module Domain
  module Services
    class BookingService
      def initialize(booking_repository, space_repository)
        @booking_repository = booking_repository
        @space_repository = space_repository
      end

      def check_availability(space_id, start_time, end_time)
        space = @space_repository.find(space_id)

        if space.nil?
          return { available: false, message: "Space not found" }
        end

        overlapping_bookings = @booking_repository.find_overlapping(space_id, start_time, end_time)

        if overlapping_bookings.empty?
          { available: true, message: "Space is available for the requested time" }
        else
          { available: false, message: "Space is not available for the requested time" }
        end
      end

      def create_booking(attributes)
        availability = check_availability(attributes[:space_id], attributes[:start_time], attributes[:end_time])

        unless availability[:available]
          return { success: false, message: availability[:message] }
        end

        booking_attributes = attributes.merge(status: "pending")
        booking = @booking_repository.create(booking_attributes)

        if booking
          { success: true, message: "Booking created successfully", booking: booking }
        else
          { success: false, message: "Failed to create booking" }
        end
      end

      def confirm_booking(booking)
        return { success: false, message: "Booking is already confirmed" } if booking.status == "confirmed"
        return { success: false, message: "Cannot confirm a cancelled booking" } if booking.status == "cancelled"

        # Create a new booking object with updated status
        updated_booking_data = booking.dup
        updated_booking_data.status = "confirmed"
        updated_booking = @booking_repository.update(updated_booking_data)

        if updated_booking
          { success: true, message: "Booking confirmed successfully", booking: updated_booking }
        else
          { success: false, message: "Failed to confirm booking" }
        end
      end

      def cancel_booking(booking)
        return { success: false, message: "Booking is already cancelled" } if booking.status == "cancelled"

        # Create a new booking object with updated status
        updated_booking_data = booking.dup
        updated_booking_data.status = "cancelled"
        updated_booking = @booking_repository.update(updated_booking_data)

        if updated_booking
          { success: true, message: "Booking cancelled successfully", booking: updated_booking }
        else
          { success: false, message: "Failed to cancel booking" }
        end
      end
    end
  end
end
