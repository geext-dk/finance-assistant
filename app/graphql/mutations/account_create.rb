# frozen_string_literal: true

module Mutations
    class AccountCreate < BaseMutation
        null true
        argument :name, String
        argument :currency, String

        type Types::AccountType

        def resolve(name:, currency:)
            Accounts::Create.call(name: name, currency: currency, user: current_user)
        end
    end
end