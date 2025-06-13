# frozen_string_literal: true

# This file defines the Users module namespace within Application::UseCases
module Application
  module UseCases
    # Users module contains user-related use cases
    module Users
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/application/use_cases/users.rb to define Users
Users = Application::UseCases::Users
