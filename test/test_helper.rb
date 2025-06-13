ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

module Domain
  class Booking
    include ActiveModel::Validations

    attr_accessor :id, :space_id, :user_id, :start_time, :end_time, :status

    validates :space_id, :user_id, :start_time, :end_time, :status, presence: true
    validate :end_time_after_start_time
    validate :not_in_past

    def initialize(attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end

    private

    def end_time_after_start_time
      return unless start_time && end_time
      errors.add(:end_time, "must be after start time") if end_time <= start_time
    end

    def not_in_past
      return unless start_time
      errors.add(:start_time, "cannot be in the past") if start_time < Time.now
    end
  end

  class Space
    attr_accessor :id, :name, :description, :capacity, :space_type

    def initialize(attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end
  end

  class User
    attr_accessor :id, :name, :email

    def initialize(attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end
  end
end

unless defined?(Space)
  class Space < ApplicationRecord
    self.table_name = "spaces"

    has_many :bookings
  end
end

unless defined?(Booking)
  class Booking < ApplicationRecord
    self.table_name = "bookings"

    belongs_to :space
    belongs_to :user
  end
end

unless defined?(User)
  class User < ApplicationRecord
    self.table_name = "users"

    has_many :bookings
  end
end

module Infrastructure
  module Repositories
    class SpaceRepository
      def find_by_id(id)
        space = Space.find_by(id: id)
        return nil unless space

        Domain::Space.new(
          id: space.id,
          name: space.name,
          description: space.description,
          capacity: space.capacity,
          space_type: space.space_type
        )
      end

      def find_all
        Space.all.map do |space|
          Domain::Space.new(
            id: space.id,
            name: space.name,
            description: space.description,
            capacity: space.capacity,
            space_type: space.space_type
          )
        end
      end

      def save(domain_space)
        space = Space.find_by(id: domain_space.id) || Space.new
        space.name = domain_space.name
        space.description = domain_space.description
        space.capacity = domain_space.capacity
        space.space_type = domain_space.space_type
        space.save
      end

      def is_available?(space_id, start_time, end_time)
        overlapping = Booking.where(space_id: space_id)
                            .where("(start_time <= ? AND end_time >= ?) OR
                                    (start_time <= ? AND end_time >= ?) OR
                                    (start_time >= ? AND end_time <= ?)",
                                    start_time, start_time,
                                    end_time, end_time,
                                    start_time, end_time)
        overlapping.empty?
      end
    end

    class BookingRepository
      def find_by_id(id)
        booking = Booking.find_by(id: id)
        return nil unless booking

        to_domain_entity(booking)
      end

      def find_by_user(user_id)
        Booking.where(user_id: user_id).map do |booking|
          to_domain_entity(booking)
        end
      end

      def find_by_space(space_id)
        Booking.where(space_id: space_id).map do |booking|
          to_domain_entity(booking)
        end
      end

      def save(domain_booking)
        booking = Booking.find_by(id: domain_booking.id) || Booking.new
        booking.space_id = domain_booking.space_id
        booking.user_id = domain_booking.user_id
        booking.start_time = domain_booking.start_time
        booking.end_time = domain_booking.end_time
        booking.status = domain_booking.status
        booking.save
      end

      def update_status(id, status)
        booking = Booking.find_by(id: id)
        return false unless booking

        booking.status = status
        booking.save
      end

      def delete(id)
        booking = Booking.find_by(id: id)
        return false unless booking

        booking.destroy
        true
      end

      private

      def to_domain_entity(booking)
        Domain::Booking.new(
          id: booking.id,
          space_id: booking.space_id,
          user_id: booking.user_id,
          start_time: booking.start_time,
          end_time: booking.end_time,
          status: booking.status
        )
      end
    end

    class UserRepository
      def find_by_id(id)
        user = User.find_by(id: id)
        return nil unless user

        to_domain_entity(user)
      end

      def find_by_email(email)
        user = User.find_by(email: email)
        return nil unless user

        to_domain_entity(user)
      end

      def find_all
        User.all.map do |user|
          to_domain_entity(user)
        end
      end

      def save(domain_user)
        user = User.find_by(id: domain_user.id) || User.new
        user.name = domain_user.name
        user.email = domain_user.email
        user.save
      end

      private

      def to_domain_entity(user)
        Domain::User.new(
          id: user.id,
          name: user.name,
          email: user.email
        )
      end
    end
  end

  module Services
    class NotificationService
      def notify_booking_created(booking)
        # In a real implementation, this would send emails, push notifications, etc.
        # For testing purposes, we'll just return true
        true
      end

      def notify_booking_updated(booking)
        # Mock implementation
        true
      end

      def notify_booking_cancelled(booking)
        # Mock implementation
        true
      end
    end
  end
end

module Application
  module UseCases
    class CreateBooking
      attr_reader :space_repository, :user_repository, :booking_repository, :notification_service

      def initialize(space_repository:, user_repository:, booking_repository:, notification_service:)
        @space_repository = space_repository
        @user_repository = user_repository
        @booking_repository = booking_repository
        @notification_service = notification_service
      end

      def execute(space_id:, user_id:, start_time:, end_time:, status:)
        space = space_repository.find_by_id(space_id)
        user = user_repository.find_by_id(user_id)

        return OpenStruct.new(success?: false, message: "Space not found", booking: nil) unless space
        return OpenStruct.new(success?: false, message: "User not found", booking: nil) unless user

        unless space_repository.is_available?(space_id, start_time, end_time)
          return OpenStruct.new(success?: false, message: "Space is not available during the requested time", booking: nil)
        end

        booking = Domain::Booking.new(
          space_id: space_id,
          user_id: user_id,
          start_time: start_time,
          end_time: end_time,
          status: status
        )

        if booking_repository.save(booking)
          notification_service.notify_booking_created(booking)
          OpenStruct.new(success?: true, message: "Booking created successfully", booking: booking)
        else
          OpenStruct.new(success?: false, message: "Failed to create booking", booking: nil)
        end
      end
    end
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
