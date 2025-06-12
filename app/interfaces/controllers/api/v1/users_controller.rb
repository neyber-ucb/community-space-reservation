module Interfaces
  module Controllers
    module Api
      module V1
        class UsersController < ApplicationController
          skip_before_action :authenticate_request, only: [:create]
          
          # POST /api/v1/users
          def create
            register_user = Application::UseCases::Users::RegisterUser.new(user_repository)
            result = register_user.execute(
              name: user_params[:name],
              email: user_params[:email],
              password: user_params[:password]
            )
            
            if result[:success]
              render json: { message: result[:message], user: user_to_json(result[:user]) }, status: :created
            else
              render json: { error: result[:message] }, status: :unprocessable_entity
            end
          end
          
          # GET /api/v1/users/me
          def me
            render json: { user: user_to_json(current_user) }
          end
          
          private
          
          def user_params
            params.require(:user).permit(:name, :email, :password)
          end
          
          def user_repository
            @user_repository ||= Infrastructure::Repositories::ActiveRecordUserRepository.new
          end
          
          def user_to_json(user)
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
  end
end
