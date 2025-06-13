# frozen_string_literal: true

# This file defines the Repositories module namespace within Infrastructure
module Infrastructure
  # Repositories module contains repository implementations
  module Repositories
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/infrastructure/repositories.rb to define Repositories
Repositories = Infrastructure::Repositories
