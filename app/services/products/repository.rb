# frozen_string_literal: true

module Products
  class Repository < BaseRepository
    class << self
      private

      # @return [Class<Product>]
      def record
        Product
      end

      def type_name
        Products::Constants::PRODUCT_TYPE_NAME
      end

      # @return [ActiveRecord::Relation<Product>]
      def query(include_archived:)
        include_archived ? Product.all : Product.where(archived_at: nil)
      end
    end
  end
end
