class User < ApplicationRecord
  has_many :products
  has_many :transactions
  has_many :accounts
  has_many :merchants

  has_secure_password

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
