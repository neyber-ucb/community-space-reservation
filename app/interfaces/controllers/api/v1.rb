# frozen_string_literal: true

# This file defines the V1 module namespace within Interfaces::Controllers::Api
module Interfaces
  module Controllers
    module Api
      # V1 module contains API v1 controllers
      module V1
      end
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/interfaces/controllers/api/v1.rb to define V1
V1 = Interfaces::Controllers::Api::V1
