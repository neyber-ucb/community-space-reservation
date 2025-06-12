module Infrastructure
  module Repositories
    class ActiveRecordSpaceRepository < ::Domain::Repositories::SpaceRepository
      def find(id)
        # Use direct SQL instead of Space model
        result = ActiveRecord::Base.connection.execute(
          "SELECT * FROM spaces WHERE id = #{ActiveRecord::Base.connection.quote(id)} LIMIT 1"
        ).first
        
        return nil unless result
        map_to_entity_from_hash(result)
      end
      
      def all
        # Use direct SQL instead of Space model
        results = ActiveRecord::Base.connection.execute("SELECT * FROM spaces")
        results.map { |result| map_to_entity_from_hash(result) }
      end
      
      def find_by_category(category)
        # Use direct SQL instead of Space model
        results = ActiveRecord::Base.connection.execute(
          "SELECT * FROM spaces WHERE category = #{ActiveRecord::Base.connection.quote(category)}"
        )
        results.map { |result| map_to_entity_from_hash(result) }
      end
      
      def create(space)
        # Use direct SQL for insertion
        sql = <<-SQL
          INSERT INTO spaces (
            name, description, capacity, category, location, price_per_hour, created_at, updated_at
          ) VALUES (
            #{ActiveRecord::Base.connection.quote(space.name)},
            #{ActiveRecord::Base.connection.quote(space.description)},
            #{ActiveRecord::Base.connection.quote(space.capacity)},
            #{ActiveRecord::Base.connection.quote(space.category)},
            #{ActiveRecord::Base.connection.quote(space.location)},
            #{ActiveRecord::Base.connection.quote(space.price_per_hour)},
            NOW(),
            NOW()
          )
          RETURNING *
        SQL
        
        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          map_to_entity_from_hash(result)
        rescue => e
          Rails.logger.error "Failed to create space: #{e.message}"
          nil
        end
      end
      
      def update(space)
        # Start building the SQL update statement
        set_clauses = []
        set_clauses << "name = #{ActiveRecord::Base.connection.quote(space.name)}" if space.name
        set_clauses << "description = #{ActiveRecord::Base.connection.quote(space.description)}" if space.description
        set_clauses << "capacity = #{ActiveRecord::Base.connection.quote(space.capacity)}" if space.capacity
        set_clauses << "category = #{ActiveRecord::Base.connection.quote(space.category)}" if space.category
        set_clauses << "location = #{ActiveRecord::Base.connection.quote(space.location)}" if space.location
        set_clauses << "price_per_hour = #{ActiveRecord::Base.connection.quote(space.price_per_hour)}" if space.price_per_hour
        set_clauses << "updated_at = NOW()"
        
        # Return early if nothing to update
        return false if set_clauses.empty?
        
        # Execute the update
        sql = <<-SQL
          UPDATE spaces
          SET #{set_clauses.join(", ")}
          WHERE id = #{ActiveRecord::Base.connection.quote(space.id)}
          RETURNING *
        SQL
        
        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          return false unless result
          true
        rescue => e
          Rails.logger.error "Failed to update space: #{e.message}"
          false
        end
      end
      
      def delete(id)
        # Use direct SQL for deletion
        sql = "DELETE FROM spaces WHERE id = #{ActiveRecord::Base.connection.quote(id)}"
        
        begin
          ActiveRecord::Base.connection.execute(sql)
          true
        rescue => e
          Rails.logger.error "Failed to delete space: #{e.message}"
          false
        end
      end
      
      private
      
      def map_to_entity_from_hash(space_hash)
        ::Domain::Entities::Space.new(
          id: space_hash["id"],
          name: space_hash["name"],
          description: space_hash["description"],
          capacity: space_hash["capacity"],
          category: space_hash["category"],
          location: space_hash["location"],
          price_per_hour: space_hash["price_per_hour"],
          created_at: space_hash["created_at"],
          updated_at: space_hash["updated_at"]
        )
      end
      
      # Keep the original method for backward compatibility
      def map_to_entity(space_record)
        ::Domain::Entities::Space.new(
          id: space_record.id,
          name: space_record.name,
          description: space_record.description,
          capacity: space_record.capacity,
          category: space_record.category,
          location: space_record.location,
          price_per_hour: space_record.price_per_hour,
          created_at: space_record.created_at,
          updated_at: space_record.updated_at
        )
      end
    end
  end
end
