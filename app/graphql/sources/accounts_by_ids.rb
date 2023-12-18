# frozen_string_literal: true

module Sources
  class AccountsByIds < GraphQL::Dataloader::Source
    def initialize(user:, include_archived:)
      @user = user
      @include_archived = include_archived
    end

    def fetch(ids)
      accounts = Accounts::GetByIds::call(account_ids: ids, user: @user, include_archived: @include_archived)

      ids.map { |id| accounts.find { |a| a.id == id }}
    end
  end
end
