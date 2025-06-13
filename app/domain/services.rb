# frozen_string_literal: true

# This file defines the Services module namespace within Domain
module Domain
  # Services module contains domain services
  module Services
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/domain/services.rb to define Services
Services = Domain::Services
