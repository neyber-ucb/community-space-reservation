# This is a delegation file that points to the actual implementation
# in the hexagonal architecture.
# We need this file because Rails expects modules in app/controllers
# but we want to keep our hexagonal architecture intact.
require_relative "../interfaces/controllers/api"

# Define the Api module to satisfy Zeitwerk autoloading
module Api
end

# The actual implementation is in Interfaces::Controllers::Api
# We're using the same name to maintain compatibility
