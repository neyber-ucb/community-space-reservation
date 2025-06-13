class User < ApplicationRecord
  has_secure_password

  has_many :bookings, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :role, presence: true, inclusion: { in: %w[user admin] }

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
