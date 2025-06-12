module Application
  module UseCases
    module Users
      class AuthenticateUser
        def initialize(user_repository)
          @user_repository = user_repository
        end

        def execute(email:, password:)
          # Find user by email
          user = @user_repository.find_by_email(email)
          return { success: false, message: "Invalid email or password" } unless user

          # Verify password
          stored_password = BCrypt::Password.new(user.password_digest)
          if stored_password == password
            # Generate JWT token
            payload = {
              user_id: user.id,
              email: user.email,
              role: user.role,
              exp: (Time.now + 24 * 3600).to_i # 24 hours expiration
            }
            token = JWT.encode(payload, ENV['JWT_SECRET'] || 'default_secret_key', 'HS256')
            
            { success: true, user: user, token: token, message: "Authentication successful" }
          else
            { success: false, message: "Invalid email or password" }
          end
        end
      end
    end
  end
end
