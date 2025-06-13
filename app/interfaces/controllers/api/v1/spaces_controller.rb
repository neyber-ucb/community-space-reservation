module Interfaces
  module Controllers
    module Api
      module V1
        class SpacesController < ApplicationController
          skip_before_action :authenticate_request, only: [ :index, :show ]
          before_action :authorize_admin, only: [ :create, :update, :destroy ]

          # GET /api/v1/spaces
          def index
            list_spaces = Application::UseCases::Spaces::ListSpaces.new(space_repository)
            result = list_spaces.execute(space_type: params[:space_type])

            render json: { spaces: result[:spaces].map { |space| space_to_json(space) } }
          end

          # GET /api/v1/spaces/:id
          def show
            space = space_repository.find(params[:id])

            if space
              render json: { space: space_to_json(space) }
            else
              render json: { error: "Space not found" }, status: :not_found
            end
          end

          # POST /api/v1/spaces
          def create
            space = Domain::Entities::Space.new(
              name: space_params[:name],
              description: space_params[:description],
              capacity: space_params[:capacity],
              space_type: space_params[:space_type]
            )

            result = space_repository.create(space)

            if result
              render json: { message: "Space created successfully", space: space_to_json(result) }, status: :created
            else
              render json: { error: "Failed to create space" }, status: :unprocessable_entity
            end
          end

          # PUT /api/v1/spaces/:id
          def update
            space = space_repository.find(params[:id])
            return render json: { error: "Space not found" }, status: :not_found unless space

            space = Domain::Entities::Space.new(
              id: space.id,
              name: space_params[:name] || space.name,
              description: space_params[:description] || space.description,
              capacity: space_params[:capacity] || space.capacity,
              space_type: space_params[:space_type] || space.space_type
            )

            result = space_repository.update(space)

            if result
              render json: { message: "Space updated successfully", space: space_to_json(result) }
            else
              render json: { error: "Failed to update space" }, status: :unprocessable_entity
            end
          end

          # DELETE /api/v1/spaces/:id
          def destroy
            result = space_repository.delete(params[:id])

            if result
              render json: { message: "Space deleted successfully" }
            else
              render json: { error: "Failed to delete space" }, status: :unprocessable_entity
            end
          end

          private

          def space_params
            params.require(:space).permit(:name, :description, :capacity, :space_type)
          end

          def space_repository
            @space_repository ||= Infrastructure::Repositories::ActiveRecordSpaceRepository.new
          end

          def space_to_json(space)
            {
              id: space.id,
              name: space.name,
              description: space.description,
              capacity: space.capacity,
              space_type: space.space_type,
              created_at: space.created_at,
              updated_at: space.updated_at
            }
          end

          def authorize_admin
            render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.admin?
          end
        end
      end
    end
  end
end
