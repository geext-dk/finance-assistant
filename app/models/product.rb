class Product < ApplicationRecord
    belongs_to :user

    enum quantity_type: { per_piece: 0, weighted: 1 }

    validates :quantity_type, presence: true, inclusion: { in: quantity_types.keys }
    validates :name, presence: true
    validates :country, presence: true, format: { with: Common::RegularExpressions::COUNTRY }
end
