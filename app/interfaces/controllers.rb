# frozen_string_literal: true

# This file defines the Controllers module namespace within Interfaces
module Interfaces
  # Controllers module contains application controllers
  module Controllers
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/interfaces/controllers.rb to define Controllers
Controllers = Interfaces::Controllers
