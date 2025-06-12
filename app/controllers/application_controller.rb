class ApplicationController < ActionController::API
  include JsonWebToken
  
  before_action :authenticate_request
  
  private
  
  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    decoded = decode_token(header)
    if decoded
      @current_user_id = decoded[0]['user_id']
    else
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
  
  def current_user
    return @current_user if @current_user
    return nil unless @current_user_id
    
    @current_user = user_repository.find(@current_user_id)
  end
  
  def user_repository
    @user_repository ||= Infrastructure::Repositories::ActiveRecordUserRepository.new
  end
end
