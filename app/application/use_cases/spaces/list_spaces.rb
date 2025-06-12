module Application
  module UseCases
    module Spaces
      class ListSpaces
        def initialize(space_repository)
          @space_repository = space_repository
        end

        def execute(space_type: nil)
          if space_type
            spaces = @space_repository.find_by_type(space_type)
          else
            spaces = @space_repository.all
          end

          { success: true, spaces: spaces }
        end
      end
    end
  end
end
