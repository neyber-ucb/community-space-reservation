# This initializer ensures models and repositories are loaded properly
# using Rails.application.config.to_prepare which runs after Rails is initialized

Rails.application.config.to_prepare do
  # Load models, entities, and repositories in the correct order
  # This block will run after Rails has loaded its core components

  # Make sure our custom directories are in the autoload paths
  Rails.autoloaders.main.push_dir(Rails.root.join("app/domain/entities"))
  Rails.autoloaders.main.push_dir(Rails.root.join("app/domain/repositories"))
  Rails.autoloaders.main.push_dir(Rails.root.join("app/infrastructure/repositories"))

  # Log that our custom paths have been added
  Rails.logger.info "Custom directories added to autoload paths"
end
