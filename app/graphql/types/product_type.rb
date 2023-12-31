# frozen_string_literal: true

module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :country, String, null: false
    field :name, String, null: false
    field :quantity_type, QuantityTypeType, null: false
  end
end
