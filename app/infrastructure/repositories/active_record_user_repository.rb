module Infrastructure
  module Repositories
    class ActiveRecordUserRepository < ::Domain::Repositories::UserRepository
      def find(id)
        # Use direct SQL instead of User model
        result = ActiveRecord::Base.connection.execute(
          "SELECT * FROM users WHERE id = #{ActiveRecord::Base.connection.quote(id)} LIMIT 1"
        ).first

        return nil unless result
        map_to_entity_from_hash(result)
      end

      def find_by_email(email)
        # Use direct SQL instead of User model
        result = ActiveRecord::Base.connection.execute(
          "SELECT * FROM users WHERE email = #{ActiveRecord::Base.connection.quote(email)} LIMIT 1"
        ).first

        return nil unless result
        map_to_entity_from_hash(result)
      end

      def all
        # Use direct SQL instead of User model
        results = ActiveRecord::Base.connection.execute("SELECT * FROM users")
        results.map { |result| map_to_entity_from_hash(result) }
      end

      def create(user)
        puts "Creating user in repository: #{user.inspect}"
        puts "Password in repository: #{user.password.inspect}"

        # Generate password digest using BCrypt
        password_digest = user.password.present? ? BCrypt::Password.create(user.password) : nil

        # Use direct SQL for insertion
        sql = <<-SQL
          INSERT INTO users (name, email, password_digest, role, created_at, updated_at)
          VALUES (
            #{ActiveRecord::Base.connection.quote(user.name)},
            #{ActiveRecord::Base.connection.quote(user.email)},
            #{ActiveRecord::Base.connection.quote(password_digest)},
            #{ActiveRecord::Base.connection.quote(user.role || 'user')},
            NOW(),
            NOW()
          )
          RETURNING *
        SQL

        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          puts "User saved successfully: #{result.inspect}"
          map_to_entity_from_hash(result)
        rescue => e
          puts "User save failed: #{e.message}"
          nil
        end
      end

      def update(user)
        # Start building the SQL update statement
        set_clauses = []
        set_clauses << "name = #{ActiveRecord::Base.connection.quote(user.name)}" if user.name
        set_clauses << "email = #{ActiveRecord::Base.connection.quote(user.email)}" if user.email
        set_clauses << "role = #{ActiveRecord::Base.connection.quote(user.role)}" if user.role

        # Handle password update if provided
        if user.password.present?
          password_digest = BCrypt::Password.create(user.password)
          set_clauses << "password_digest = #{ActiveRecord::Base.connection.quote(password_digest)}"
        end

        set_clauses << "updated_at = NOW()"

        # Return early if nothing to update
        return nil if set_clauses.empty?

        # Execute the update
        sql = <<-SQL
          UPDATE users
          SET #{set_clauses.join(", ")}
          WHERE id = #{ActiveRecord::Base.connection.quote(user.id)}
          RETURNING *
        SQL

        begin
          result = ActiveRecord::Base.connection.execute(sql).first
          return nil unless result
          map_to_entity_from_hash(result)
        rescue => e
          puts "User update failed: #{e.message}"
          nil
        end
      end

      def delete(id)
        # Use direct SQL for deletion
        sql = "DELETE FROM users WHERE id = #{ActiveRecord::Base.connection.quote(id)}"

        begin
          ActiveRecord::Base.connection.execute(sql)
          true
        rescue => e
          puts "User deletion failed: #{e.message}"
          false
        end
      end

      private

      def map_to_entity_from_hash(user_hash)
        ::Domain::Entities::User.new(
          id: user_hash["id"],
          name: user_hash["name"],
          email: user_hash["email"],
          password_digest: user_hash["password_digest"],
          role: user_hash["role"],
          created_at: user_hash["created_at"],
          updated_at: user_hash["updated_at"]
        )
      end

      # Keep the original method for backward compatibility
      def map_to_entity(user_record)
        ::Domain::Entities::User.new(
          id: user_record.id,
          name: user_record.name,
          email: user_record.email,
          password_digest: user_record.password_digest,
          role: user_record.role,
          created_at: user_record.created_at,
          updated_at: user_record.updated_at
        )
      end
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/infrastructure/repositories/active_record_user_repository.rb to define ActiveRecordUserRepository
ActiveRecordUserRepository = Infrastructure::Repositories::ActiveRecordUserRepository
