# frozen_string_literal: true

module Sources
  class ProductsByIds < GraphQL::Dataloader::Source
    def initialize(user:, include_archived:)
      @user = user
      @include_archived = include_archived
    end

    def fetch(ids)
      products = Products::GetByIds::call(product_ids: ids, user: @user, include_archived: @include_archived)

      ids.map { |id| products.find { |a| a.id == id }}
    end
  end
end
