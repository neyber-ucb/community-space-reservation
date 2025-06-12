class Space < ApplicationRecord
  has_many :bookings, dependent: :destroy
  
  validates :name, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :category, presence: true
  validates :price_per_hour, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Get all unique categories currently in use
  def self.available_categories
    distinct.pluck(:category).compact
  end
end
