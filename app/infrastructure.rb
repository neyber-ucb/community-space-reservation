# frozen_string_literal: true

# This file defines the Infrastructure module namespace
module Infrastructure
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/infrastructure.rb to define Infrastructure
Infrastructure = ::Infrastructure
