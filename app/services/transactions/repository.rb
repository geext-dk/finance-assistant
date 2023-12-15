# frozen_string_literal: true

module Transactions
  class Repository < BaseRepository
    class << self
      # @return [TransactionLineItem]
      def update_line_item(line_item, hash)
        update(line_item, hash)
      end

      private

      def record
        Transaction
      end

      def type_name
        Constants::TRANSACTION_TYPE_NAME
      end

      def query(include_archived:)
        Transaction.includes(:line_items)
      end
    end
  end
end
