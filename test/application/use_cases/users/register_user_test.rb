require 'test_helper'
require_relative '../../../../app/application/use_cases/users/register_user'

module Application
  module UseCases
    module Users
      class RegisterUserTest < ActiveSupport::TestCase
        def setup
          @user_repository = Minitest::Mock.new
          @use_case = RegisterUser.new(@user_repository)
          
          # Sample valid registration params
          @valid_params = {
            name: "Jane Smith",
            email: "jane@example.com",
            password: "secure_password123"
          }
          
          # Sample registered user
          @registered_user = Domain::Entities::User.new(
            id: 1,
            name: "Jane Smith",
            email: "jane@example.com",
            password_digest: "hashed_password",
            role: "user"
          )
        end
        
        test "registers user successfully with valid parameters" do
          # Mock repository to return nil for find_by_email (email not taken)
          @user_repository.expect :find_by_email, nil, ["jane@example.com"]
          
          # Mock repository to return registered user for create
          @user_repository.expect :create, @registered_user do |user|
            # Verify the user entity passed to create has the correct attributes
            assert_equal "Jane Smith", user.name
            assert_equal "jane@example.com", user.email
            assert_not_nil user.password_digest
            assert_equal "user", user.role
            true # Return true to indicate the block passed
          end
          
          # Execute the use case
          result = @use_case.execute(
            name: @valid_params[:name],
            email: @valid_params[:email],
            password: @valid_params[:password]
          )
          
          # Verify the result
          assert result[:success]
          assert_equal "User registered successfully", result[:message]
          
          # Verify mock expectations
          @user_repository.verify
        end
        
        test "fails registration when email is already in use" do
          # Create an existing user with the same email
          existing_user = Domain::Entities::User.new(
            id: 2,
            name: "Existing User",
            email: "jane@example.com",
            password_digest: "some_digest",
            role: "user"
          )
          
          # Mock repository to return existing user for find_by_email
          @user_repository.expect :find_by_email, existing_user, ["jane@example.com"]
          
          # Execute the use case
          result = @use_case.execute(
            name: @valid_params[:name],
            email: @valid_params[:email],
            password: @valid_params[:password]
          )
          
          # Verify the result
          assert_not result[:success]
          assert_equal "Email already in use", result[:message]
          
          # Verify mock expectations
          @user_repository.verify
        end
        
        test "fails registration when repository fails to save user" do
          # Mock repository to return nil for find_by_email (email not taken)
          @user_repository.expect :find_by_email, nil, ["jane@example.com"]
          
          # Mock repository to return nil for create (save failed)
          @user_repository.expect :create, nil do |user|
            # Verify the user entity passed to create has the correct attributes
            assert_equal "Jane Smith", user.name
            assert_equal "jane@example.com", user.email
            assert_not_nil user.password_digest
            assert_equal "user", user.role
            true # Return true to indicate the block passed
          end
          
          # Execute the use case
          result = @use_case.execute(
            name: @valid_params[:name],
            email: @valid_params[:email],
            password: @valid_params[:password]
          )
          
          # Verify the result
          assert_not result[:success]
          assert_equal "Failed to register user", result[:message]
          
          # Verify mock expectations
          @user_repository.verify
        end
        
        test "password is properly hashed during registration" do
          # Mock repository to return nil for find_by_email (email not taken)
          @user_repository.expect :find_by_email, nil, ["jane@example.com"]
          
          # Capture the user entity passed to create
          captured_user = nil
          
          # Mock repository to return registered user for create
          @user_repository.expect :create, @registered_user do |user|
            captured_user = user
            true # Return true to indicate the block passed
          end
          
          # Execute the use case
          @use_case.execute(
            name: @valid_params[:name],
            email: @valid_params[:email],
            password: @valid_params[:password]
          )
          
          # Verify that password was hashed
          assert_not_nil captured_user.password_digest
          assert_not_equal @valid_params[:password], captured_user.password_digest
          
          # Verify it's a valid BCrypt hash by checking if it can verify the original password
          password_hash = BCrypt::Password.new(captured_user.password_digest)
          assert password_hash == @valid_params[:password]
          
          # Verify mock expectations
          @user_repository.verify
        end
      end
    end
  end
end
