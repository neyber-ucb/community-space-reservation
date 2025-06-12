module Api
  module V1
    class BookingsController < ApplicationController
      before_action :set_booking, only: [:show, :update, :destroy, :confirm, :cancel]
      
      # GET /api/v1/bookings
      def index
        # Use direct SQL to get all bookings for the current user
        sql = <<-SQL
          SELECT b.*, s.name as space_name, s.category as space_category
          FROM bookings b
          JOIN spaces s ON b.space_id = s.id
          WHERE b.user_id = #{ActiveRecord::Base.connection.quote(@current_user_id)}
          ORDER BY b.start_time DESC
        SQL
        
        results = ActiveRecord::Base.connection.execute(sql)
        bookings = results.map { |result| map_to_booking_entity(result) }
        
        render json: bookings.map { |booking| serialize_booking(booking) }
      end
      
      # GET /api/v1/bookings/:id
      def show
        render json: serialize_booking(@booking)
      end
      
      # POST /api/v1/bookings
      def create
        # Extract booking parameters
        booking_params = {}
        booking_params[:user_id] = @current_user_id
        booking_params[:space_id] = params[:space_id]
        booking_params[:start_time] = params[:start_time]
        booking_params[:end_time] = params[:end_time]
        booking_params[:status] = params[:status] || 'pending'
        
        # Check for availability
        if !is_space_available?(booking_params[:space_id], booking_params[:start_time], booking_params[:end_time])
          render json: { error: "Space is not available for the selected time period" }, status: :unprocessable_entity
          return
        end
        
        # Use direct SQL for insertion
        sql = <<-SQL
          INSERT INTO bookings (
            user_id, space_id, start_time, end_time, status, created_at, updated_at
          ) VALUES (
            #{ActiveRecord::Base.connection.quote(booking_params[:user_id])},
            #{ActiveRecord::Base.connection.quote(booking_params[:space_id])},
            #{ActiveRecord::Base.connection.quote(booking_params[:start_time])},
            #{ActiveRecord::Base.connection.quote(booking_params[:end_time])},
            #{ActiveRecord::Base.connection.quote(booking_params[:status])},
            NOW(),
            NOW()
          )
          RETURNING *
        SQL
        
        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          
          # Get space details for the newly created booking
          space_sql = <<-SQL
            SELECT name, category FROM spaces WHERE id = #{ActiveRecord::Base.connection.quote(result["space_id"])}
          SQL
          space_result = ActiveRecord::Base.connection.execute(space_sql).first
          
          # Merge space details into the booking result
          result["space_name"] = space_result["name"] if space_result
          result["space_category"] = space_result["category"] if space_result
          
          booking = map_to_booking_entity(result)
          
          # Create a notification for the booking creation
          Api::V1::NotificationsController.create_notification(
            user_id: @current_user_id,
            content: "Your booking request for #{result["space_name"]} has been submitted and is pending approval.",
            notification_type: "booking_created"
          )
          
          render json: serialize_booking(booking), status: :created
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      # PUT /api/v1/bookings/:id
      def update
        # Extract booking parameters
        booking_params = {}
        booking_params[:status] = params[:status] if params[:status].present?
        booking_params[:start_time] = params[:start_time] if params[:start_time].present?
        booking_params[:end_time] = params[:end_time] if params[:end_time].present?
        
        # Check for availability if changing dates
        if (booking_params[:start_time] || booking_params[:end_time]) &&
           !is_space_available?(@booking.space_id, 
                               booking_params[:start_time] || @booking.start_time,
                               booking_params[:end_time] || @booking.end_time,
                               @booking.id)
          render json: { error: "Space is not available for the selected time period" }, status: :unprocessable_entity
          return
        end
        
        # Start building the SQL update statement
        set_clauses = []
        set_clauses << "status = #{ActiveRecord::Base.connection.quote(booking_params[:status])}" if booking_params[:status].present?
        set_clauses << "start_time = #{ActiveRecord::Base.connection.quote(booking_params[:start_time])}" if booking_params[:start_time].present?
        set_clauses << "end_time = #{ActiveRecord::Base.connection.quote(booking_params[:end_time])}" if booking_params[:end_time].present?
        set_clauses << "updated_at = NOW()"
        
        # Return early if nothing to update
        if set_clauses.empty?
          render json: { error: "No attributes to update" }, status: :unprocessable_entity
          return
        end
        
        # Execute the update
        sql = <<-SQL
          UPDATE bookings
          SET #{set_clauses.join(", ")}
          WHERE id = #{ActiveRecord::Base.connection.quote(params[:id])}
          RETURNING *
        SQL
        
        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          if result
            # Get space details for the updated booking
            space_sql = <<-SQL
              SELECT name, category FROM spaces WHERE id = #{ActiveRecord::Base.connection.quote(result["space_id"])}
            SQL
            space_result = ActiveRecord::Base.connection.execute(space_sql).first
            
            # Merge space details into the booking result
            result["space_name"] = space_result["name"] if space_result
            result["space_category"] = space_result["category"] if space_result
            
            booking = map_to_booking_entity(result)
            
            # Create a notification if status was updated
            if booking_params[:status].present?
              notification_content = case booking_params[:status]
                                    when 'confirmed'
                                      "Your booking for #{result["space_name"]} has been confirmed."
                                    when 'cancelled'
                                      "Your booking for #{result["space_name"]} has been cancelled."
                                    when 'rejected'
                                      "Your booking request for #{result["space_name"]} has been rejected."
                                    else
                                      "Your booking for #{result["space_name"]} has been updated to status: #{booking_params[:status]}."
                                    end
              
              Api::V1::NotificationsController.create_notification(
                user_id: @current_user_id,
                content: notification_content,
                notification_type: "booking_#{booking_params[:status]}"
              )
            end
            
            render json: serialize_booking(booking)
          else
            render json: { error: "Booking not found" }, status: :not_found
          end
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/bookings/:id
      def destroy
        # Get space details before deletion for notification
        space_name = @booking.instance_variable_get(:@space_name)
        
        # Use direct SQL for deletion
        sql = "DELETE FROM bookings WHERE id = #{ActiveRecord::Base.connection.quote(params[:id])}"
        
        begin
          ActiveRecord::Base.connection.execute(sql)
          
          # Create a notification for the booking deletion
          Api::V1::NotificationsController.create_notification(
            user_id: @current_user_id,
            content: "Your booking for #{space_name} has been deleted.",
            notification_type: "booking_deleted"
          )
          
          head :no_content
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      # POST /api/v1/bookings/:id/confirm
      def confirm
        update_booking_status('confirmed')
      end
      
      # POST /api/v1/bookings/:id/cancel
      def cancel
        update_booking_status('cancelled')
      end
      
      private
      
      def update_booking_status(status)
        sql = <<-SQL
          UPDATE bookings
          SET status = #{ActiveRecord::Base.connection.quote(status)}, updated_at = NOW()
          WHERE id = #{ActiveRecord::Base.connection.quote(params[:id])}
          RETURNING *
        SQL
        
        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          if result
            # Get space details for the updated booking
            space_sql = <<-SQL
              SELECT name, category FROM spaces WHERE id = #{ActiveRecord::Base.connection.quote(result["space_id"])}
            SQL
            space_result = ActiveRecord::Base.connection.execute(space_sql).first
            
            # Merge space details into the booking result
            result["space_name"] = space_result["name"] if space_result
            result["space_category"] = space_result["category"] if space_result
            
            booking = map_to_booking_entity(result)
            
            # Create a notification for the status change
            notification_content = case status
                                  when 'confirmed'
                                    "Your booking for #{result["space_name"]} has been confirmed."
                                  when 'cancelled'
                                    "Your booking for #{result["space_name"]} has been cancelled."
                                  else
                                    "Your booking status has been updated to: #{status}."
                                  end
            
            Api::V1::NotificationsController.create_notification(
              user_id: @current_user_id,
              content: notification_content,
              notification_type: "booking_#{status}"
            )
            
            render json: serialize_booking(booking)
          else
            render json: { error: "Booking not found" }, status: :not_found
          end
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      def set_booking
        # Use direct SQL to find the booking
        sql = <<-SQL
          SELECT b.*, s.name as space_name, s.category as space_category
          FROM bookings b
          JOIN spaces s ON b.space_id = s.id
          WHERE b.id = #{ActiveRecord::Base.connection.quote(params[:id])}
          AND b.user_id = #{ActiveRecord::Base.connection.quote(@current_user_id)}
          LIMIT 1
        SQL
        
        result = ActiveRecord::Base.connection.execute(sql).first
        
        unless result
          render json: { error: "Booking not found" }, status: :not_found
          return
        end
        
        @booking = map_to_booking_entity(result)
      end
      
      def is_space_available?(space_id, start_time, end_time, exclude_booking_id = nil)
        # Check if there are any overlapping bookings
        sql = <<-SQL
          SELECT COUNT(*) as count
          FROM bookings
          WHERE space_id = #{ActiveRecord::Base.connection.quote(space_id)}
          AND status = 'confirmed'
          AND (
            (start_time <= #{ActiveRecord::Base.connection.quote(start_time)} AND end_time > #{ActiveRecord::Base.connection.quote(start_time)})
            OR
            (start_time < #{ActiveRecord::Base.connection.quote(end_time)} AND end_time >= #{ActiveRecord::Base.connection.quote(end_time)})
            OR
            (start_time >= #{ActiveRecord::Base.connection.quote(start_time)} AND end_time <= #{ActiveRecord::Base.connection.quote(end_time)})
          )
        SQL
        
        # Exclude the current booking if updating
        if exclude_booking_id
          sql += " AND id != #{ActiveRecord::Base.connection.quote(exclude_booking_id)}"
        end
        
        result = ActiveRecord::Base.connection.execute(sql).first
        result["count"].to_i == 0
      end
      
      def map_to_booking_entity(booking_hash)
        # Create a booking entity
        booking = ::Domain::Entities::Booking.new(
          id: booking_hash["id"],
          user_id: booking_hash["user_id"],
          space_id: booking_hash["space_id"],
          start_time: booking_hash["start_time"],
          end_time: booking_hash["end_time"],
          status: booking_hash["status"],
          created_at: booking_hash["created_at"],
          updated_at: booking_hash["updated_at"]
        )
        
        # Add space_name and space_category as instance variables
        booking.instance_variable_set(:@space_name, booking_hash["space_name"])
        booking.instance_variable_set(:@space_category, booking_hash["space_category"])
        
        booking
      end
      
      def serialize_booking(booking)
        {
          id: booking.id,
          user_id: booking.user_id,
          space_id: booking.space_id,
          space_name: booking.instance_variable_get(:@space_name),
          space_category: booking.instance_variable_get(:@space_category),
          start_time: booking.start_time,
          end_time: booking.end_time,
          status: booking.status,
          duration_in_hours: booking.duration_in_hours,
          created_at: booking.created_at,
          updated_at: booking.updated_at
        }
      end
    end
  end
end
