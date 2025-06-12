module Domain
  module Repositories
    class SpaceRepository
      def find(id)
        raise NotImplementedError
      end

      def all
        raise NotImplementedError
      end

      def find_by_type(space_type)
        raise NotImplementedError
      end

      def create(space)
        raise NotImplementedError
      end

      def update(space)
        raise NotImplementedError
      end

      def delete(id)
        raise NotImplementedError
      end
    end
  end
end
