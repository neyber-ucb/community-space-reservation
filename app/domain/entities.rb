# frozen_string_literal: true

# This file defines the Entities module namespace within Domain
module Domain
  # Entities module contains all domain entities
  module Entities
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/domain/entities.rb to define Entities
Entities = Domain::Entities
