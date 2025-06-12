module Application
  module UseCases
    module Users
      class CreateUser
        def initialize(user_repository)
          @user_repository = user_repository
        end
        
        def execute(params)
          # Convert params to symbols if they're strings
          params = params.transform_keys(&:to_sym) if params.respond_to?(:transform_keys)
          
          # Validate required fields
          return failure("Name is required") if params[:name].blank?
          return failure("Email is required") if params[:email].blank?
          return failure("Password is required") if params[:password].blank?
          
          # Check if email is already taken
          if @user_repository.find_by_email(params[:email])
            return failure("Email is already taken")
          end
          
          # Create user entity
          user = Domain::Entities::User.new(
            id: nil,
            name: params[:name],
            email: params[:email],
            password: params[:password],
            role: params[:role] || 'user'
          )
          
          # Save user to repository
          created_user = @user_repository.create(user)
          
          # Return success result with created user
          success(created_user)
        end
        
        private
        
        def success(user)
          OpenStruct.new(success?: true, user: user)
        end
        
        def failure(error)
          OpenStruct.new(success?: false, error: error)
        end
      end
    end
  end
end
