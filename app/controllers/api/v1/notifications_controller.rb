module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :set_notification, only: [:show, :mark_as_read]
      
      # GET /api/v1/notifications
      def index
        # Use direct SQL to get all notifications for the current user
        sql = <<-SQL
          SELECT * FROM notifications
          WHERE user_id = #{ActiveRecord::Base.connection.quote(@current_user_id)}
          ORDER BY created_at DESC
        SQL
        
        results = ActiveRecord::Base.connection.execute(sql)
        notifications = results.map { |result| serialize_notification(result) }
        
        render json: notifications
      end
      
      # GET /api/v1/notifications/unread
      def unread
        # Use direct SQL to get unread notifications for the current user
        sql = <<-SQL
          SELECT * FROM notifications
          WHERE user_id = #{ActiveRecord::Base.connection.quote(@current_user_id)}
          AND read = FALSE
          ORDER BY created_at DESC
        SQL
        
        results = ActiveRecord::Base.connection.execute(sql)
        notifications = results.map { |result| serialize_notification(result) }
        
        render json: notifications
      end
      
      # GET /api/v1/notifications/:id
      def show
        # Mark the notification as read when viewed
        update_read_status(@notification[:id], true)
        
        render json: @notification
      end
      
      # PATCH /api/v1/notifications/:id/read
      def mark_as_read
        # Update the read status to true
        Rails.logger.info("Marking notification as read: #{params[:id]}")
        Rails.logger.info("Notification object: #{@notification.inspect}")
        
        update_read_status(params[:id], true)
        
        render json: { 
          message: "Notification marked as read",
          notification: @notification
        }
      end
      
      # PATCH /api/v1/notifications/read_all
      def mark_all_as_read
        # Use direct SQL to mark all notifications as read
        sql = <<-SQL
          UPDATE notifications
          SET read = TRUE, updated_at = NOW()
          WHERE user_id = #{ActiveRecord::Base.connection.quote(@current_user_id)}
          AND read = FALSE
          RETURNING *
        SQL
        
        begin
          results = ActiveRecord::Base.connection.execute(sql)
          notifications = results.map { |result| serialize_notification(result) }
          
          render json: { 
            message: "#{notifications.count} notifications marked as read",
            notifications: notifications
          }
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      # Class method to create a notification from any controller
      def self.create_notification(user_id:, content:, notification_type:)
        # Use direct SQL for insertion
        sql = <<-SQL
          INSERT INTO notifications (
            user_id, content, notification_type, read, created_at, updated_at
          ) VALUES (
            #{ActiveRecord::Base.connection.quote(user_id)},
            #{ActiveRecord::Base.connection.quote(content)},
            #{ActiveRecord::Base.connection.quote(notification_type)},
            FALSE,
            NOW(),
            NOW()
          )
          RETURNING *
        SQL
        
        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          return result
        rescue => e
          Rails.logger.error("Failed to create notification: #{e.message}")
          return nil
        end
      end
      
      private
      
      def set_notification
        # Use direct SQL to find the notification
        sql = <<-SQL
          SELECT * FROM notifications
          WHERE id = #{ActiveRecord::Base.connection.quote(params[:id])}
          AND user_id = #{ActiveRecord::Base.connection.quote(@current_user_id)}
          LIMIT 1
        SQL
        
        result = ActiveRecord::Base.connection.execute(sql).first
        
        unless result
          render json: { error: "Notification not found" }, status: :not_found
          return
        end
        
        @notification = serialize_notification(result)
      end
      
      def update_read_status(notification_id, read_status)
        # Use direct SQL to update the read status
        # Convert boolean to PostgreSQL's TRUE/FALSE literals
        pg_boolean = read_status ? "TRUE" : "FALSE"
        
        sql = <<-SQL
          UPDATE notifications
          SET read = #{pg_boolean}, updated_at = NOW()
          WHERE id = #{ActiveRecord::Base.connection.quote(notification_id)}
          AND user_id = #{ActiveRecord::Base.connection.quote(@current_user_id)}
          RETURNING *
        SQL
        
        Rails.logger.info("Executing SQL: #{sql}")
        result = ActiveRecord::Base.connection.execute(sql).first
        Rails.logger.info("Update result: #{result.inspect}")
        
        if result
          @notification = serialize_notification(result)
        end
      end
      
      def serialize_notification(notification_hash)
        {
          id: notification_hash["id"],
          user_id: notification_hash["user_id"],
          content: notification_hash["content"],
          notification_type: notification_hash["notification_type"],
          read: notification_hash["read"],
          created_at: notification_hash["created_at"],
          updated_at: notification_hash["updated_at"]
        }
      end
    end
  end
end
