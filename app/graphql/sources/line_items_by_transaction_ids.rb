# frozen_string_literal: true

module Sources
  class LineItemsByTransactionIds < GraphQL::Dataloader::Source
    def initialize(user:)
      @user = user
    end

    def fetch(transaction_ids)
      line_items = Transactions::GetLineItemsByTransactionIds::call(user: @user, transaction_ids: transaction_ids)

      transaction_ids.map { |t_id| line_items.filter { |li| li.owner_transaction_id == t_id } }
    end
  end
end
