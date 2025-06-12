module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_request, only: [:login]
      
      def login
        # Extract parameters, prioritizing root level parameters
        auth_params = {}
        auth_params[:email] = params[:email] if params[:email].present?
        auth_params[:password] = params[:password] if params[:password].present?
        
        # If any parameters are missing, try to get them from the nested authentication hash
        if params[:authentication].present?
          auth_params[:email] ||= params[:authentication][:email]
          auth_params[:password] ||= params[:authentication][:password]
        end
        
        Rails.logger.debug "Auth params after processing: #{auth_params.inspect}"
        
        # Use direct SQL to find the user to avoid model loading issues
        user_record = ActiveRecord::Base.connection.execute(
          "SELECT * FROM users WHERE email = '#{ActiveRecord::Base.connection.quote_string(auth_params[:email])}' LIMIT 1"
        ).first
        
        if user_record
          # Verify password using BCrypt directly to avoid model dependencies
          stored_password_digest = user_record["password_digest"]
          authenticated = BCrypt::Password.new(stored_password_digest) == auth_params[:password]
          
          if authenticated
            # Generate JWT token directly
            user_id = user_record["id"]
            token = encode_token({ user_id: user_id })
            render json: { token: token }, status: :ok
          else
            render json: { error: 'Invalid credentials' }, status: :unauthorized
          end
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end
      
      private
      
      def encode_token(payload)
        JWT.encode(payload, ENV['JWT_SECRET'] || 'default_secret_key')
      end
    end
  end
end
