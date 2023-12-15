# frozen_string_literal: true

module Types
  class MerchantType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :country, String, null: false
  end
end
