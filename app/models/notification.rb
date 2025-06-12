class Notification < ApplicationRecord
  belongs_to :user
  
  validates :content, presence: true
  validates :notification_type, presence: true, inclusion: { in: %w[email system] }
  validates :read, inclusion: { in: [true, false] }
  
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :email_type, -> { where(notification_type: 'email') }
  scope :system_type, -> { where(notification_type: 'system') }
  
  def mark_as_read!
    update(read: true)
  end
end
