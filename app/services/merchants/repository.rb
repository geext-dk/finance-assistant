# frozen_string_literal: true

module Merchants
  class Repository < BaseRepository
    class << self
      private

      def record
        Merchant
      end

      def type_name
        Merchants::Constants::MERCHANT_TYPE_NAME
      end

      def query(include_archived:)
        include_archived ? Merchant.all : Merchant.where(archived_at: nil)
      end
    end
  end
end
