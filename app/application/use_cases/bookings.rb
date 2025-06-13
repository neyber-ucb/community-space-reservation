# frozen_string_literal: true

# This file defines the Bookings module namespace within Application::UseCases
module Application
  module UseCases
    # Bookings module contains booking-related use cases
    module Bookings
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/application/use_cases/bookings.rb to define Bookings
Bookings = Application::UseCases::Bookings
