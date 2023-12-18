class Merchant < ApplicationRecord
  include UserOwned, Archivable

  belongs_to :user

  validates :name, presence: true
  validates :country, presence: true, format: { with: Common::RegularExpressions::COUNTRY }
end
