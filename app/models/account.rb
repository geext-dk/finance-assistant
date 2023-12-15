class Account < ApplicationRecord
    belongs_to :user

    validates :name, presence: true
    validates :currency, presence: true, format: { with: /[A-Z]{3}/ }
end
