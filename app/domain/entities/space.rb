# frozen_string_literal: true

# First, ensure the parent modules exist
module Domain; end
module Domain::Entities; end

# Then define the Space class
class Domain::Entities::Space
  attr_accessor :id, :name, :description, :capacity, :category, 
                :created_at, :updated_at, :space_type, :amenities
  
  def initialize(id:, name:, description:, capacity:, category: nil, 
                 created_at: nil, updated_at: nil, space_type: nil, amenities: [])
    @id = id
    @name = name
    @description = description
    @capacity = capacity
    @category = category
    @created_at = created_at
    @updated_at = updated_at
    @space_type = space_type
    @amenities = amenities
  end
end

# Make the class accessible at the top level for the controller
::Space = ::Domain::Entities::Space unless defined?(::Space)
