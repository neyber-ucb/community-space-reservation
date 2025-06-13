# frozen_string_literal: true

# This file defines the Repositories module namespace within Domain
module Domain
  # Repositories module contains domain repositories
  module Repositories
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/domain/repositories.rb to define Repositories
Repositories = Domain::Repositories
