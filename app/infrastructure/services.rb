# frozen_string_literal: true

# This file defines the Services module namespace within Infrastructure
module Infrastructure
  # Services module contains infrastructure services
  module Services
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/infrastructure/services.rb to define Services
Services = Infrastructure::Services
