class Account < ApplicationRecord
    include UserOwned, Archivable

    belongs_to :user

    validates :name, presence: true
    validates :currency, presence: true, format: { with: Common::RegularExpressions::CURRENCY }
end
