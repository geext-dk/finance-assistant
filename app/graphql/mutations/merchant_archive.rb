# frozen_string_literal: true

module Mutations
  class MerchantArchive < BaseMutation
    null true
    argument :merchant_id, ID

    type Types::MerchantType

    def resolve(merchant_id:)
      Merchants::Archive.call(merchant_id: merchant_id, user: current_user)
    end
  end
end
