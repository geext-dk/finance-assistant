class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :merchant
  belongs_to :account
  has_many :line_items, class_name: "TransactionLineItem", foreign_key: :owner_transaction_id

  validates :merchant_id, presence: true
  validates :account_id, presence: true
  validates :country, presence: true
  validates :currency, presence: true
  validates :date, presence: true
end
