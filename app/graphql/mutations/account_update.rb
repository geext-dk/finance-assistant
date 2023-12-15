# frozen_string_literal: true

module Mutations
  class AccountUpdate < BaseMutation
    null true
    argument :account_id, ID
    argument :name, String

    type Types::AccountType

    def resolve(account_id:, name:)
      Accounts::Update.call(account_id: account_id, name: name, user: current_user)
    end
  end
end