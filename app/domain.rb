# frozen_string_literal: true

# This file defines the Domain module namespace
module Domain
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/domain.rb to define Domain
Domain = ::Domain
