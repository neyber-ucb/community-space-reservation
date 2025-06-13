# Explicitly require all hexagonal architecture modules to ensure they're loaded
# This is necessary because Rails' autoloading might not find modules in non-standard directories

# Domain layer
require_relative "../../app/domain/entities/user"
require_relative "../../app/domain/repositories/user_repository"

# Application layer
require_relative "../../app/application/use_cases/users/create_user"

# Infrastructure layer
require_relative "../../app/infrastructure/repositories/active_record_user_repository"
require_relative "../../app/infrastructure/factories/service_factory"

# Make sure the Infrastructure module is loaded in the global namespace
Infrastructure = ::Infrastructure unless defined?(Infrastructure)
