class Transaction < ApplicationRecord
  include UserOwned

  belongs_to :user

  belongs_to :merchant
  belongs_to :account
  has_many :line_items, class_name: "TransactionLineItem", foreign_key: :owner_transaction_id

  validates :country, presence: true, format: { with: Common::RegularExpressions::COUNTRY }
  validates :currency, presence: true, format: { with: Common::RegularExpressions::CURRENCY }
  validates :date, presence: true
end
