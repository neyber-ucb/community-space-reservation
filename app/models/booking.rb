class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :space
  
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending confirmed cancelled] }
  validate :end_time_after_start_time
  validate :no_overlapping_bookings, on: :create
  
  scope :pending, -> { where(status: 'pending') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :active, -> { where.not(status: 'cancelled') }
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :past, -> { where('end_time < ?', Time.current) }
  scope :for_date_range, ->(start_date, end_date) { where('start_time >= ? AND end_time <= ?', start_date, end_date) }
  
  def duration_in_hours
    ((end_time - start_time) / 1.hour).round(2)
  end
  
  private
  
  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    
    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end
  
  def no_overlapping_bookings
    return if space.nil? || start_time.blank? || end_time.blank?
    
    overlapping_bookings = Booking.active
                                  .where(space_id: space_id)
                                  .where('(start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?) OR (start_time >= ? AND end_time <= ?)', 
                                         start_time, start_time, end_time, end_time, start_time, end_time)
    
    if overlapping_bookings.exists?
      errors.add(:base, "There is already a booking for this space during the selected time")
    end
  end
end
