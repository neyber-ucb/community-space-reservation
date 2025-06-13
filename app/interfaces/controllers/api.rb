# frozen_string_literal: true

# This file defines the API module namespace within Interfaces::Controllers
module Interfaces
  module Controllers
    # API module contains API controllers
    module Api
    end
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/interfaces/controllers/api.rb to define Api
Api = Interfaces::Controllers::Api
