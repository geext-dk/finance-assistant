# frozen_string_literal: true

module Mutations
  class MerchantUpdate < BaseMutation
    null true
    argument :merchant_id, ID
    argument :name, String

    type Types::MerchantType

    def resolve(merchant_id:, name:)
      Merchants::Update.call(merchant_id: merchant_id, name: name, user: current_user)
    end
  end
end
