module Domain
  module Repositories
    class BookingRepository
      def find(id)
        raise NotImplementedError
      end

      def all
        raise NotImplementedError
      end

      def find_by_user(user_id)
        raise NotImplementedError
      end

      def find_by_space(space_id)
        raise NotImplementedError
      end

      def find_by_date_range(start_date, end_date)
        raise NotImplementedError
      end

      def find_overlapping(space_id, start_time, end_time)
        raise NotImplementedError
      end

      def create(booking)
        raise NotImplementedError
      end

      def update(booking)
        raise NotImplementedError
      end

      def delete(id)
        raise NotImplementedError
      end
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/domain/repositories/booking_repository.rb to define BookingRepository
BookingRepository = Domain::Repositories::BookingRepository
