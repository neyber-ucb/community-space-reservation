module Interfaces
  module Controllers
    module Api
      module V1
        class NotificationsController < ApplicationController
          # GET /api/v1/notifications
          def index
            notifications = notification_repository.find_by_user(current_user.id)
            
            render json: { 
              notifications: notifications.map { |notification| notification_to_json(notification) }
            }
          end
          
          # GET /api/v1/notifications/unread
          def unread
            notifications = notification_repository.find_unread_by_user(current_user.id)
            
            render json: { 
              notifications: notifications.map { |notification| notification_to_json(notification) }
            }
          end
          
          # GET /api/v1/notifications/:id
          def show
            notification = notification_repository.find(params[:id])
            
            if notification && notification.user_id == current_user.id
              render json: { notification: notification_to_json(notification) }
            else
              render json: { error: "Notification not found" }, status: :not_found
            end
          end
          
          # PATCH /api/v1/notifications/:id/read
          def mark_as_read
            notification = notification_repository.find(params[:id])
            
            if notification && notification.user_id == current_user.id
              if notification_repository.mark_as_read(notification.id)
                render json: { message: "Notification marked as read" }
              else
                render json: { error: "Failed to mark notification as read" }, status: :unprocessable_entity
              end
            else
              render json: { error: "Notification not found" }, status: :not_found
            end
          end
          
          # PATCH /api/v1/notifications/read_all
          def mark_all_as_read
            if notification_repository.mark_all_as_read(current_user.id)
              render json: { message: "All notifications marked as read" }
            else
              render json: { error: "Failed to mark notifications as read" }, status: :unprocessable_entity
            end
          end
          
          private
          
          def notification_repository
            @notification_repository ||= Infrastructure::Repositories::ActiveRecordNotificationRepository.new
          end
          
          def notification_to_json(notification)
            {
              id: notification.id,
              content: notification.content,
              notification_type: notification.notification_type,
              read: notification.read,
              created_at: notification.created_at,
              updated_at: notification.updated_at
            }
          end
        end
      end
    end
  end
end
