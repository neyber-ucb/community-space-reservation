module Infrastructure
  module Repositories
    class ActiveRecordBookingRepository < Domain::Repositories::BookingRepository
      def find(id)
        booking_record = Booking.find_by(id: id)
        return nil unless booking_record

        map_to_entity(booking_record)
      end

      def all
        Booking.all.map { |booking_record| map_to_entity(booking_record) }
      end

      def find_by_user(user_id)
        Booking.where(user_id: user_id).map { |booking_record| map_to_entity(booking_record) }
      end

      def find_by_space(space_id)
        Booking.where(space_id: space_id).map { |booking_record| map_to_entity(booking_record) }
      end

      def find_by_date_range(start_date, end_date)
        Booking.where("start_time >= ? AND end_time <= ?", start_date, end_date)
               .map { |booking_record| map_to_entity(booking_record) }
      end

      def find_overlapping(space_id, start_time, end_time)
        Booking.where(space_id: space_id)
               .where("(start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?) OR (start_time >= ? AND end_time <= ?)",
                      start_time, start_time, end_time, end_time, start_time, end_time)
               .where.not(status: "cancelled")
               .map { |booking_record| map_to_entity(booking_record) }
      end

      def create(booking)
        booking_record = Booking.new(
          user_id: booking.user_id,
          space_id: booking.space_id,
          start_time: booking.start_time,
          end_time: booking.end_time,
          status: booking.status
        )

        return nil unless booking_record.save

        map_to_entity(booking_record)
      end

      def update(booking)
        booking_record = Booking.find_by(id: booking.id)
        return nil unless booking_record

        booking_record.user_id = booking.user_id if booking.user_id
        booking_record.space_id = booking.space_id if booking.space_id
        booking_record.start_time = booking.start_time if booking.start_time
        booking_record.end_time = booking.end_time if booking.end_time
        booking_record.status = booking.status if booking.status

        return nil unless booking_record.save

        map_to_entity(booking_record)
      end

      def delete(id)
        booking_record = Booking.find_by(id: id)
        return false unless booking_record

        booking_record.destroy
        true
      end

      private

      def map_to_entity(booking_record)
        Domain::Entities::Booking.new(
          id: booking_record.id,
          user_id: booking_record.user_id,
          space_id: booking_record.space_id,
          start_time: booking_record.start_time,
          end_time: booking_record.end_time,
          status: booking_record.status,
          created_at: booking_record.created_at,
          updated_at: booking_record.updated_at
        )
      end
    end
  end
end
