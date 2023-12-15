# frozen_string_literal: true

module Mutations
  class AccountArchive < BaseMutation
    null true
    argument :account_id, ID

    type Types::AccountType

    def resolve(account_id:)
      Accounts::Archive.call(
        account_id: account_id,
        user: current_user)
    end
  end
end

