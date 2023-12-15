# frozen_string_literal: true

module Mutations
  class MerchantCreate < BaseMutation
    null true
    argument :name, String
    argument :country, String

    type Types::MerchantType

    def resolve(name:, country:)
      Merchants::Create.call(name: name, country: country, user: current_user)
    end
  end
end
