module Api
  module V1
    class SpacesController < ApplicationController
      before_action :set_space, only: [:show, :update, :destroy]
      
      # GET /api/v1/spaces
      def index
        # Use direct SQL instead of repository
        results = ActiveRecord::Base.connection.execute("SELECT * FROM spaces")
        spaces = results.map { |result| map_to_space_entity(result) }
        render json: spaces.map { |space| serialize_space(space) }
      end
      
      # GET /api/v1/spaces/categories
      def categories
        # Get distinct categories from the database
        results = ActiveRecord::Base.connection.execute("SELECT DISTINCT category FROM spaces")
        categories = results.map { |result| result["category"] }.compact
        render json: { categories: categories }
      end
      
      # GET /api/v1/spaces/:id
      def show
        render json: serialize_space(@space)
      end
      
      # POST /api/v1/spaces
      def create
        # Extract parameters, prioritizing root level parameters
        space_params = {}
        space_params[:name] = params[:name] if params[:name].present?
        space_params[:description] = params[:description] if params[:description].present?
        space_params[:capacity] = params[:capacity] if params[:capacity].present?
        # Handle both category and space_type parameters
        space_params[:category] = params[:category] || params[:space_type] if params[:category].present? || params[:space_type].present?
        
        # If any parameters are missing, try to get them from the nested space hash
        if params[:space].present?
          space_params[:name] ||= params[:space][:name]
          space_params[:description] ||= params[:space][:description]
          space_params[:capacity] ||= params[:space][:capacity]
          # Handle both category and space_type parameters in the nested hash
          space_params[:category] ||= params[:space][:category] || params[:space][:space_type]
        end
        
        Rails.logger.debug "Space params after processing: #{space_params.inspect}"
        
        # Use direct SQL for insertion
        sql = <<-SQL
          INSERT INTO spaces (
            name, description, capacity, category, created_at, updated_at
          ) VALUES (
            #{ActiveRecord::Base.connection.quote(space_params[:name])},
            #{ActiveRecord::Base.connection.quote(space_params[:description])},
            #{ActiveRecord::Base.connection.quote(space_params[:capacity])},
            #{ActiveRecord::Base.connection.quote(space_params[:category])},
            NOW(),
            NOW()
          )
          RETURNING *
        SQL
        
        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          space = map_to_space_entity(result)
          render json: serialize_space(space), status: :created
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      # PUT /api/v1/spaces/:id
      def update
        # Extract parameters, prioritizing root level parameters
        space_params = {}
        space_params[:name] = params[:name] if params[:name].present?
        space_params[:description] = params[:description] if params[:description].present?
        space_params[:capacity] = params[:capacity] if params[:capacity].present?
        # Handle both category and space_type parameters
        space_params[:category] = params[:category] || params[:space_type] if params[:category].present? || params[:space_type].present?
        
        # If any parameters are missing, try to get them from the nested space hash
        if params[:space].present?
          space_params[:name] ||= params[:space][:name]
          space_params[:description] ||= params[:space][:description]
          space_params[:capacity] ||= params[:space][:capacity]
          # Handle both category and space_type parameters in the nested hash
          space_params[:category] ||= params[:space][:category] || params[:space][:space_type]
        end
        
        Rails.logger.debug "Space update params after processing: #{space_params.inspect}"
        
        # Start building the SQL update statement
        set_clauses = []
        set_clauses << "name = #{ActiveRecord::Base.connection.quote(space_params[:name])}" if space_params[:name].present?
        set_clauses << "description = #{ActiveRecord::Base.connection.quote(space_params[:description])}" if space_params[:description].present?
        set_clauses << "capacity = #{ActiveRecord::Base.connection.quote(space_params[:capacity])}" if space_params[:capacity].present?
        set_clauses << "category = #{ActiveRecord::Base.connection.quote(space_params[:category])}" if space_params[:category].present?
        set_clauses << "updated_at = NOW()"
        
        # Return early if nothing to update
        if set_clauses.empty?
          render json: { error: "No attributes to update" }, status: :unprocessable_entity
          return
        end
        
        # Execute the update
        sql = <<-SQL
          UPDATE spaces
          SET #{set_clauses.join(", ")}
          WHERE id = #{ActiveRecord::Base.connection.quote(params[:id])}
          RETURNING *
        SQL
        
        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          if result
            space = map_to_space_entity(result)
            render json: serialize_space(space)
          else
            render json: { error: "Space not found" }, status: :not_found
          end
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/spaces/:id
      def destroy
        # Use direct SQL for deletion
        sql = "DELETE FROM spaces WHERE id = #{ActiveRecord::Base.connection.quote(params[:id])}"
        
        begin
          ActiveRecord::Base.connection.execute(sql)
          head :no_content
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_space
        # Use direct SQL to find the space
        result = ActiveRecord::Base.connection.execute(
          "SELECT * FROM spaces WHERE id = #{ActiveRecord::Base.connection.quote(params[:id])} LIMIT 1"
        ).first
        
        unless result
          render json: { error: "Space not found" }, status: :not_found
          return
        end
        
        @space = map_to_space_entity(result)
      end
      
      def map_to_space_entity(space_hash)
        ::Domain::Entities::Space.new(
          id: space_hash["id"],
          name: space_hash["name"],
          description: space_hash["description"],
          capacity: space_hash["capacity"],
          category: space_hash["category"],
          created_at: space_hash["created_at"],
          updated_at: space_hash["updated_at"]
        )
      end
      
      def serialize_space(space)
        {
          id: space.id,
          name: space.name,
          description: space.description,
          capacity: space.capacity,
          category: space.category,
          created_at: space.created_at,
          updated_at: space.updated_at
        }
      end
    end
  end
end
