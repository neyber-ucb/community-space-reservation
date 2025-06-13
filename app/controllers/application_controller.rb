# This file defines the ApplicationController for the traditional Rails structure
# while maintaining compatibility with our hexagonal architecture
require 'jwt'

# Define the ApplicationController class to satisfy Zeitwerk autoloading
class ApplicationController < ActionController::API
  # Include JWT functionality directly
  def encode_token(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, ENV["JWT_SECRET"] || "default_secret_key", "HS256")
  end

  def decode_token(token)
    begin
      JWT.decode(token, ENV["JWT_SECRET"] || "default_secret_key", true, { algorithm: "HS256" })
    rescue JWT::DecodeError
      nil
    end
  end

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
    @current_user ||= User.find(@current_user_id) if @current_user_id
  end
end
