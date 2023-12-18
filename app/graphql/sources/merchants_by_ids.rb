# frozen_string_literal: true

module Sources
  class MerchantsByIds < GraphQL::Dataloader::Source
    def initialize(user:, include_archived:)
      @user = user
      @include_archived = include_archived
    end

    def fetch(ids)
      merchants = Merchants::GetByIds::call(merchant_ids: ids, user: @user, include_archived: @include_archived)

      ids.map { |id| merchants.find { |a| a.id == id }}
    end
  end
end
