module Domain
  module Entities
    class Booking
      attr_accessor :id, :user_id, :space_id, :start_time, :end_time, :status,
                    :created_at, :updated_at

      def initialize(id:, user_id:, space_id:, start_time:, end_time:, status:,
                     created_at:, updated_at:)
        @id = id
        @user_id = user_id
        @space_id = space_id
        @start_time = start_time
        @end_time = end_time
        @status = status
        @created_at = created_at
        @updated_at = updated_at
      end

      def duration_in_hours
        return 0 unless start_time && end_time
        ((end_time - start_time) / 3600).round(2)
      end

      def pending?
        status == "pending"
      end

      def confirmed?
        status == "confirmed"
      end

      def cancelled?
        status == "cancelled"
      end
    end
  end
end
