# frozen_string_literal: true

require "test_helper"

class TransactionsGetLineItemsByTransactionIdsTest < ActiveSupport::TestCase
  test "Should get line items by transaction ids" do
    # Arrange
    sample_transaction_1 = create(:transaction)
    create(:transaction_line_item, owner_transaction: sample_transaction_1)
    create(:transaction_line_item, owner_transaction: sample_transaction_1)

    sample_transaction_2 = create(:transaction, user: sample_transaction_1.user)
    create(:transaction_line_item, owner_transaction: sample_transaction_2)
    create(:transaction_line_item, owner_transaction: sample_transaction_2)

    sample_transaction_3 = create(:transaction, user: sample_transaction_1.user)
    create(:transaction_line_item, owner_transaction: sample_transaction_3)
    create(:transaction_line_item, owner_transaction: sample_transaction_3)

    result_ids = sample_transaction_1.line_items.map { |li| li.product_id }.union(
      sample_transaction_2.line_items.map { |li| li.product_id }
    )

    # Act
    results = Transactions::GetLineItemsByTransactionIds::call(
      transaction_ids: [sample_transaction_1.id, sample_transaction_2.id],
      user: Users::SessionUser.new(sample_transaction_1.user.id)
    )

    # Assert
    assert_equal 4, results.length
    assert_equal result_ids.sort, results.map { |li| li.product_id }.sort
  end

  test "Should not return line items if transaction belongs to another user" do
    # Arrange
    sample_transaction_1 = create(:transaction)
    create(:transaction_line_item, owner_transaction: sample_transaction_1)
    create(:transaction_line_item, owner_transaction: sample_transaction_1)

    # Act
    results = Transactions::GetLineItemsByTransactionIds::call(
      transaction_ids: [sample_transaction_1.id],
      user: Users::SessionUser.new("some-user")
    )

    # Assert
    assert_equal 0, results.length
  end
end
