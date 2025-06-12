module Domain
  module Repositories
    class UserRepository
      def find(id)
        raise NotImplementedError
      end

      def find_by_email(email)
        raise NotImplementedError
      end

      def all
        raise NotImplementedError
      end

      def create(user)
        raise NotImplementedError
      end

      def update(user)
        raise NotImplementedError
      end

      def delete(id)
        raise NotImplementedError
      end
    end
  end
end
