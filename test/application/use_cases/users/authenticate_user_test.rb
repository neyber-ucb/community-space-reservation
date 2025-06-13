require 'test_helper'
require_relative '../../../../app/application/use_cases/users/authenticate_user'

module Application
  module UseCases
    module Users
      class AuthenticateUserTest < ActiveSupport::TestCase
        def setup
          @user_repository = Minitest::Mock.new
          @use_case = AuthenticateUser.new(@user_repository)
          
          # Create a test user with known password
          @user = Domain::Entities::User.new(
            id: 1,
            name: "Test User",
            email: "test@example.com",
            password_digest: BCrypt::Password.create("password123"),
            role: "user"
          )
        end
        
        test "authenticates user with valid credentials" do
          # Mock the repository to return our test user
          @user_repository.expect :find_by_email, @user, ["test@example.com"]
          
          # Set JWT_SECRET for consistent token generation in tests
          original_jwt_secret = ENV['JWT_SECRET']
          ENV['JWT_SECRET'] = 'test_secret_key'
          
          # Execute the use case
          result = @use_case.execute(email: "test@example.com", password: "password123")
          
          # Verify the result
          assert result[:success]
          assert_equal @user, result[:user]
          assert_not_nil result[:token]
          assert_equal "Authentication successful", result[:message]
          
          # Verify the JWT token contains expected payload
          token = result[:token]
          decoded_token = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: 'HS256' })[0]
          assert_equal 1, decoded_token["user_id"]
          assert_equal "test@example.com", decoded_token["email"]
          assert_equal "user", decoded_token["role"]
          
          # Reset environment variable
          ENV['JWT_SECRET'] = original_jwt_secret
          
          # Verify mock expectations
          @user_repository.verify
        end
        
        test "fails authentication with invalid email" do
          # Mock the repository to return nil (user not found)
          @user_repository.expect :find_by_email, nil, ["nonexistent@example.com"]
          
          # Execute the use case
          result = @use_case.execute(email: "nonexistent@example.com", password: "password123")
          
          # Verify the result
          assert_not result[:success]
          assert_equal "Invalid email or password", result[:message]
          assert_nil result[:token]
          
          # Verify mock expectations
          @user_repository.verify
        end
        
        test "fails authentication with invalid password" do
          # Mock the repository to return our test user
          @user_repository.expect :find_by_email, @user, ["test@example.com"]
          
          # Execute the use case with wrong password
          result = @use_case.execute(email: "test@example.com", password: "wrong_password")
          
          # Verify the result
          assert_not result[:success]
          assert_equal "Invalid email or password", result[:message]
          assert_nil result[:token]
          
          # Verify mock expectations
          @user_repository.verify
        end
      end
    end
  end
end
