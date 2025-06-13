# frozen_string_literal: true

# This file defines the Factories module namespace within Infrastructure
module Infrastructure
  # Factories module contains service factories
  module Factories
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/infrastructure/factories.rb to define Factories
Factories = Infrastructure::Factories
