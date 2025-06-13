require 'test_helper'
require_relative '../../../../app/application/use_cases/spaces/list_spaces'
require_relative '../../../../app/domain/entities/space'

module Application
  module UseCases
    module Spaces
      class ListSpacesTest < ActiveSupport::TestCase
        def setup
          @space_repository = Minitest::Mock.new
          @use_case = ListSpaces.new(@space_repository)
          
          # Sample spaces for testing
          @conference_room = Domain::Entities::Space.new(
            id: 1,
            name: "Conference Room A",
            description: "Large conference room with projector",
            capacity: 20,
            space_type: "conference_room",
            amenities: ["projector", "whiteboard", "video_conferencing"]
          )
          
          @classroom = Domain::Entities::Space.new(
            id: 2,
            name: "Classroom 101",
            description: "Medium-sized classroom for workshops",
            capacity: 30,
            space_type: "classroom",
            amenities: ["whiteboard", "desks", "chairs"]
          )
          
          @office = Domain::Entities::Space.new(
            id: 3,
            name: "Private Office",
            description: "Small private office for meetings",
            capacity: 4,
            space_type: "office",
            amenities: ["desk", "chairs", "wifi"]
          )
          
          @all_spaces = [@conference_room, @classroom, @office]
          @conference_rooms = [@conference_room]
        end
        
        test "lists all spaces when no type is specified" do
          # Mock repository to return all spaces
          @space_repository.expect :all, @all_spaces
          
          # Execute the use case
          result = @use_case.execute
          
          # Verify the result
          assert result[:success]
          assert_equal @all_spaces, result[:spaces]
          assert_equal 3, result[:spaces].length
          
          # Verify mock expectations
          @space_repository.verify
        end
        
        test "lists spaces by type when type is specified" do
          # Mock repository to return spaces filtered by type
          @space_repository.expect :find_by_type, @conference_rooms, ["conference_room"]
          
          # Execute the use case
          result = @use_case.execute(space_type: "conference_room")
          
          # Verify the result
          assert result[:success]
          assert_equal @conference_rooms, result[:spaces]
          assert_equal 1, result[:spaces].length
          assert_equal "Conference Room A", result[:spaces].first.name
          
          # Verify mock expectations
          @space_repository.verify
        end
        
        test "returns empty array when no spaces match the specified type" do
          # Mock repository to return empty array for a type with no spaces
          @space_repository.expect :find_by_type, [], ["lounge"]
          
          # Execute the use case
          result = @use_case.execute(space_type: "lounge")
          
          # Verify the result
          assert result[:success]
          assert_equal [], result[:spaces]
          assert_equal 0, result[:spaces].length
          
          # Verify mock expectations
          @space_repository.verify
        end
      end
    end
  end
end
