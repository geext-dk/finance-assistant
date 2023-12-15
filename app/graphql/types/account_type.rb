# frozen_string_literal: true

module Types
  class AccountType < Types::BaseObject
    field :id, ID, description: "Id of the account", null: false
    field :name, String, description: "Name of the account", null: false
    field :currency, String, "Currency of the account", null: false
  end
end
