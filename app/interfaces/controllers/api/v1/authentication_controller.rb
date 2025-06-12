module Interfaces
  module Controllers
    module Api
      module V1
        class AuthenticationController < ApplicationController
          skip_before_action :authenticate_request
          
          # POST /api/v1/auth/login
          def login
            authenticate_user = Application::UseCases::Users::AuthenticateUser.new(user_repository)
            result = authenticate_user.execute(
              email: auth_params[:email],
              password: auth_params[:password]
            )
            
            if result[:success]
              render json: {
                message: result[:message],
                token: result[:token],
                user: {
                  id: result[:user].id,
                  name: result[:user].name,
                  email: result[:user].email,
                  role: result[:user].role
                }
              }
            else
              render json: { error: result[:message] }, status: :unauthorized
            end
          end
          
          private
          
          def auth_params
            # Try to get parameters from root level first, then from nested authentication hash
            {
              email: params[:email] || (params[:authentication] && params[:authentication][:email]),
              password: params[:password] || (params[:authentication] && params[:authentication][:password])
            }
          end
          
          def user_repository
            @user_repository ||= Infrastructure::Repositories::ActiveRecordUserRepository.new
          end
        end
      end
    end
  end
end
