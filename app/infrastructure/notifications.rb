# frozen_string_literal: true

# This file defines the Notifications module namespace within Infrastructure
module Infrastructure
  # Notifications module contains notification services
  module Notifications
  end
end

# Define a top-level constant to satisfy Zeitwerk autoloading
# This is necessary because Zeitwerk expects app/infrastructure/notifications.rb to define Notifications
Notifications = Infrastructure::Notifications
