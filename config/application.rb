require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CommunitySpaceReservation
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configure autoload paths for hexagonal architecture
    config.autoload_paths += %W[
      #{config.root}/app
      #{config.root}/app/domain
      #{config.root}/app/domain/entities
      #{config.root}/app/domain/repositories
      #{config.root}/app/infrastructure
      #{config.root}/app/infrastructure/repositories
    ]

    # Also add these paths to eager load paths to ensure they're loaded in production
    config.eager_load_paths += %W[
      #{config.root}/app/domain
      #{config.root}/app/domain/entities
      #{config.root}/app/domain/repositories
      #{config.root}/app/infrastructure
      #{config.root}/app/infrastructure/repositories
    ]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
