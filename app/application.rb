# frozen_string_literal: true

# This file defines the Application module namespace
module Application
  # Application module contains use cases and application services
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/application.rb to define Application
Application = ::Application
