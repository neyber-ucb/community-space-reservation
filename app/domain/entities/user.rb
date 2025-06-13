module Domain
  module Entities
    class User
      attr_reader :id, :email, :name, :password_digest, :role, :created_at, :updated_at
      attr_accessor :password

      def initialize(**attributes)
        @id = attributes[:id]
        @email = attributes[:email]
        @name = attributes[:name]
        @password = attributes[:password]
        @password_digest = attributes[:password_digest]
        @role = attributes[:role] || "user"
        @created_at = attributes[:created_at]
        @updated_at = attributes[:updated_at]
      end

      def admin?
        role == "admin"
      end
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/domain/entities/user.rb to define User
User = Domain::Entities::User
