# This is a delegation controller that points to the actual implementation
# in the hexagonal architecture.
# We need this file because Rails expects controllers in app/controllers
# but we want to keep our hexagonal architecture intact.
require_relative '../interfaces/controllers/application_controller'

# The actual implementation is in Interfaces::Controllers::ApplicationController
# We're not redefining ApplicationController here, just referencing it
