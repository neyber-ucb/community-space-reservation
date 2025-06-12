module Domain
  module Entities
    class Space
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
  end
end
