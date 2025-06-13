# frozen_string_literal: true

# This file defines the Concerns module namespace within Interfaces::Controllers
module Interfaces
  module Controllers
    # Concerns module contains controller concerns
    module Concerns
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/interfaces/controllers/concerns.rb to define Concerns
Concerns = Interfaces::Controllers::Concerns
