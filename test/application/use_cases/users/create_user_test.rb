require 'test_helper'
require_relative '../../../../app/application/use_cases/users/create_user'

module Application
  module UseCases
    module Users
      class CreateUserTest < ActiveSupport::TestCase
        def setup
          @user_repository = Minitest::Mock.new
          @use_case = CreateUser.new(@user_repository)
          
          # Sample valid user params
          @valid_params = {
            name: "John Doe",
            email: "john@example.com",
            password: "secure_password123"
          }
          
          # Sample created user
          @created_user = Domain::Entities::User.new(
            id: 1,
            name: "John Doe",
            email: "john@example.com",
            password_digest: "hashed_password",
            role: "user"
          )
        end
        
        test "creates user successfully with valid parameters" do
          # Mock repository to return nil for find_by_email (email not taken)
          @user_repository.expect :find_by_email, nil, ["john@example.com"]
          
          # Mock repository to return created user for create
          @user_repository.expect :create, @created_user do |user|
            # Verify the user entity passed to create has the correct attributes
            assert_equal "John Doe", user.name
            assert_equal "john@example.com", user.email
            assert_not_nil user.password
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
          assert result.success?
          assert_equal @created_user, result.user
          
          # Verify mock expectations
          @user_repository.verify
        end
        
        test "fails when name is blank" do
          # Execute the use case with blank name
          result = @use_case.execute(
            name: "",
            email: @valid_params[:email],
            password: @valid_params[:password]
          )
          
          # Verify the result
          assert_not result.success?
          assert_equal "Name is required", result.error
        end
        
        test "fails when email is blank" do
          # Execute the use case with blank email
          result = @use_case.execute(
            name: @valid_params[:name],
            email: "",
            password: @valid_params[:password]
          )
          
          # Verify the result
          assert_not result.success?
          assert_equal "Email is required", result.error
        end
        
        test "fails when password is blank" do
          # Execute the use case with blank password
          result = @use_case.execute(
            name: @valid_params[:name],
            email: @valid_params[:email],
            password: ""
          )
          
          # Verify the result
          assert_not result.success?
          assert_equal "Password is required", result.error
        end
        
        test "fails when email is already taken" do
          # Create an existing user with the same email
          existing_user = Domain::Entities::User.new(
            id: 2,
            name: "Existing User",
            email: "john@example.com",
            password_digest: "some_digest",
            role: "user"
          )
          
          # Mock repository to return existing user for find_by_email
          @user_repository.expect :find_by_email, existing_user, ["john@example.com"]
          
          # Execute the use case
          result = @use_case.execute(
            name: @valid_params[:name],
            email: @valid_params[:email],
            password: @valid_params[:password]
          )
          
          # Verify the result
          assert_not result.success?
          assert_equal "Email is already taken", result.error
          
          # Verify mock expectations
          @user_repository.verify
        end
        
        test "creates admin user when role is specified" do
          # Mock repository to return nil for find_by_email (email not taken)
          @user_repository.expect :find_by_email, nil, ["admin@example.com"]
          
          # Create an admin user
          admin_user = Domain::Entities::User.new(
            id: 3,
            name: "Admin User",
            email: "admin@example.com",
            password_digest: "admin_password_hash",
            role: "admin"
          )
          
          # Mock repository to return admin user for create
          @user_repository.expect :create, admin_user do |user|
            # Verify the user entity passed to create has the correct attributes
            assert_equal "Admin User", user.name
            assert_equal "admin@example.com", user.email
            assert_not_nil user.password
            assert_equal "admin", user.role
            true # Return true to indicate the block passed
          end
          
          # Execute the use case with admin role
          result = @use_case.execute(
            name: "Admin User",
            email: "admin@example.com",
            password: "admin_password",
            role: "admin"
          )
          
          # Verify the result
          assert result.success?
          assert_equal admin_user, result.user
          
          # Verify mock expectations
          @user_repository.verify
        end
      end
    end
  end
end
