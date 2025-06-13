module Interfaces
  module Controllers
    class ApplicationController < ActionController::API
      include JsonWebToken

      before_action :authenticate_request

      private

      def authenticate_request
        header = request.headers["Authorization"]
        header = header.split(" ").last if header

        begin
          decoded = decode_token(header)
          @current_user_id = decoded[0]["user_id"] if decoded
        rescue JWT::DecodeError
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      end

      def current_user
        @current_user ||= Infrastructure::Repositories::ActiveRecordUserRepository.new.find(@current_user_id) if @current_user_id
      end
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/interfaces/controllers/application_controller.rb to define ApplicationController
ApplicationController = Interfaces::Controllers::ApplicationController
