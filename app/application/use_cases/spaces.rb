# frozen_string_literal: true

# This file defines the Spaces module namespace within Application::UseCases
module Application
  module UseCases
    # Spaces module contains space-related use cases
    module Spaces
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/application/use_cases/spaces.rb to define Spaces
Spaces = Application::UseCases::Spaces
