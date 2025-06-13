# frozen_string_literal: true

# This file defines the UseCases module namespace within Application
module Application
  # UseCases module contains application use cases
  module UseCases
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/application/use_cases.rb to define UseCases
UseCases = Application::UseCases
