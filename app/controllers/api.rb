# This is a delegation file that points to the actual implementation
# in the hexagonal architecture.
# We need this file because Rails expects modules in app/controllers
# but we want to keep our hexagonal architecture intact.
require_relative '../interfaces/controllers/api'

# The actual implementation is in Interfaces::Controllers::Api
# We're not redefining Api here, just referencing it
