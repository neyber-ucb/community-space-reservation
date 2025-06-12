module Application
  module UseCases
    module Users
      class RegisterUser
        def initialize(user_repository)
          @user_repository = user_repository
        end

        def execute(name:, email:, password:)
          # Check if user already exists
          existing_user = @user_repository.find_by_email(email)
          return { success: false, message: "Email already in use" } if existing_user

          # Create password digest
          password_digest = BCrypt::Password.create(password)

          # Create user entity
          user = Domain::Entities::User.new(
            name: name,
            email: email,
            password_digest: password_digest,
            role: 'user'
          )

          # Save user
          result = @user_repository.create(user)
          
          if result
            { success: true, user: result, message: "User registered successfully" }
          else
            { success: false, message: "Failed to register user" }
          end
        end
      end
    end
  end
end
