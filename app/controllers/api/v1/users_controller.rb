module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_request, only: [:create]
      
      def create
        # Add debugging to see what parameters are being received
        Rails.logger.debug "Parameters received: #{params.inspect}"
        
        # Extract parameters, prioritizing root level parameters
        user_params = {}
        user_params[:name] = params[:name] if params[:name].present?
        user_params[:email] = params[:email] if params[:email].present?
        user_params[:password] = params[:password] if params[:password].present?
        
        # If any parameters are missing, try to get them from the nested user hash
        if params[:user].present?
          user_params[:name] ||= params[:user][:name]
          user_params[:email] ||= params[:user][:email]
          user_params[:password] ||= params[:user][:password]
        end
        
        Rails.logger.debug "User params after processing: #{user_params.inspect}"
        
        result = ::Infrastructure::Factories::ServiceFactory.create_user_use_case.execute(user_params)
        
        if result.success?
          render json: serialize_user(result.user), status: :created
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end
      
      def me
        render json: serialize_user(current_user), status: :ok
      end
      
      private
      
      def serialize_user(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end
