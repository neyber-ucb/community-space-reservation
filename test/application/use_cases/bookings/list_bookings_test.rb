require 'test_helper'
require_relative '../../../../app/application/use_cases/bookings/list_bookings'
require_relative '../../../../app/domain/entities/booking'
require_relative '../../../../app/domain/entities/space'

module Application
  module UseCases
    module Bookings
      class ListBookingsTest < ActiveSupport::TestCase
        def setup
          @booking_repository = Minitest::Mock.new
          @space_repository = Minitest::Mock.new
          @use_case = ListBookings.new(@booking_repository, @space_repository)
          
          # Sample dates for testing
          @today = Time.now
          @tomorrow = @today + 1.day
          
          # Sample bookings
          @booking1 = Domain::Entities::Booking.new(
            id: 1,
            user_id: 2,
            space_id: 3,
            start_time: @today + 2.hours,
            end_time: @today + 4.hours,
            status: 'confirmed',
            created_at: @today - 1.day,
            updated_at: @today - 1.day
          )
          
          @booking2 = Domain::Entities::Booking.new(
            id: 2,
            user_id: 2,
            space_id: 4,
            start_time: @tomorrow,
            end_time: @tomorrow + 2.hours,
            status: 'pending',
            created_at: @today,
            updated_at: @today
          )
          
          @booking3 = Domain::Entities::Booking.new(
            id: 3,
            user_id: 5,
            space_id: 3,
            start_time: @tomorrow + 4.hours,
            end_time: @tomorrow + 6.hours,
            status: 'confirmed',
            created_at: @today,
            updated_at: @today
          )
          
          # Sample spaces
          @space1 = Domain::Entities::Space.new(
            id: 3,
            name: "Conference Room A",
            description: "Large conference room",
            capacity: 20,
            space_type: "conference_room",
            amenities: ["projector", "whiteboard"]
          )
          
          @space2 = Domain::Entities::Space.new(
            id: 4,
            name: "Office Space B",
            description: "Small office space",
            capacity: 4,
            space_type: "office",
            amenities: ["desk", "chairs"]
          )
          
          # Collections
          @all_bookings = [@booking1, @booking2, @booking3]
          @user_bookings = [@booking1, @booking2]
          @space_bookings = [@booking1, @booking3]
          @date_range_bookings = [@booking2, @booking3]
        end
        
        test "lists all bookings when no filters are provided" do
          # Mock repository to return all bookings
          @booking_repository.expect :all, @all_bookings
          
          # Execute the use case
          result = @use_case.execute
          
          # Verify the result
          assert result[:success]
          assert_equal @all_bookings, result[:bookings]
          assert_equal 3, result[:bookings].length
          
          # Verify mock expectations
          @booking_repository.verify
        end
        
        test "filters bookings by user_id" do
          # Mock repository to return bookings for user 2
          @booking_repository.expect :find_by_user, @user_bookings, [2]
          
          # Execute the use case
          result = @use_case.execute(user_id: 2)
          
          # Verify the result
          assert result[:success]
          assert_equal @user_bookings, result[:bookings]
          assert_equal 2, result[:bookings].length
          assert_equal 2, result[:bookings][0].user_id
          assert_equal 2, result[:bookings][1].user_id
          
          # Verify mock expectations
          @booking_repository.verify
        end
        
        test "filters bookings by space_id" do
          # Mock repository to return bookings for space 3
          @booking_repository.expect :find_by_space, @space_bookings, [3]
          
          # Execute the use case
          result = @use_case.execute(space_id: 3)
          
          # Verify the result
          assert result[:success]
          assert_equal @space_bookings, result[:bookings]
          assert_equal 2, result[:bookings].length
          assert_equal 3, result[:bookings][0].space_id
          assert_equal 3, result[:bookings][1].space_id
          
          # Verify mock expectations
          @booking_repository.verify
        end
        
        test "filters bookings by date range" do
          # Mock repository to return bookings within date range
          @booking_repository.expect :find_by_date_range, @date_range_bookings, [@tomorrow, @tomorrow + 6.hours]
          
          # Execute the use case
          result = @use_case.execute(start_date: @tomorrow, end_date: @tomorrow + 6.hours)
          
          # Verify the result
          assert result[:success]
          assert_equal @date_range_bookings, result[:bookings]
          assert_equal 2, result[:bookings].length
          
          # Verify mock expectations
          @booking_repository.verify
        end
        
        test "includes space details when requested" do
          # Mock repository to return bookings for user 2
          @booking_repository.expect :find_by_user, @user_bookings, [2]
          
          # Mock space repository to return spaces
          @space_repository.expect :find, @space1, [3]
          @space_repository.expect :find, @space2, [4]
          
          # Execute the use case
          result = @use_case.execute(user_id: 2, include_space_details: true)
          
          # Verify the result
          assert result[:success]
          assert_equal 2, result[:bookings].length
          
          # Check that bookings include space details
          assert_equal @booking1, result[:bookings][0][:booking]
          assert_equal @space1, result[:bookings][0][:space]
          assert_equal @booking2, result[:bookings][1][:booking]
          assert_equal @space2, result[:bookings][1][:space]
          
          # Verify mock expectations
          @booking_repository.verify
          @space_repository.verify
        end
        
        test "returns empty array when no bookings match filters" do
          # Mock repository to return empty array
          @booking_repository.expect :find_by_user, [], [999]
          
          # Execute the use case
          result = @use_case.execute(user_id: 999)
          
          # Verify the result
          assert result[:success]
          assert_equal [], result[:bookings]
          assert_equal 0, result[:bookings].length
          
          # Verify mock expectations
          @booking_repository.verify
        end
      end
    end
  end
end
