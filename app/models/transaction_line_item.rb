class TransactionLineItem < ApplicationRecord
  belongs_to :product
  belongs_to :owner_transaction, class_name: 'Transaction'

  validates :owner_transaction_id, presence: true
  validates :product_id, presence: true
  validates :price_cents, presence: true
  validates :quantity_pieces, presence: true, unless: -> (li) { li.quantity_weighted.present? }
  validates :quantity_weighted, presence: true, unless: -> (li) { li.quantity_pieces.present? }
  validates :total_price_cents, presence: true
end
