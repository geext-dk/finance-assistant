# frozen_string_literal: true

require "test_helper"

class TransactionsRemoveLineItemTest < ActiveSupport::TestCase
  test "Should remove line item" do
    # Arrange
    transaction = create(:transaction)
    line_item = create(:transaction_line_item, owner_transaction: transaction)

    # Act
    Transactions::RemoveLineItem::call(
      transaction_id: transaction.id,
      product_id: line_item.product_id,
      user: Users::SessionUser.new(transaction.user.id)
    )

    # Assert
    assert_equal 0, transaction.line_items.length
  end

  test "Should raise if the transaction was not found" do
    assert_raise NotFoundError do
      Transactions::RemoveLineItem::call(
        transaction_id: "some-transaction-id",
        product_id: "some-product-id",
        user: Users::SessionUser.new("some-user")
      )
    end
  end

  test "Should raise if the line item was not found" do
    # Arrange
    transaction = create(:transaction)
    create(:transaction_line_item, owner_transaction: transaction)

    # Act & Assert
    assert_raise NotFoundError do
      Transactions::RemoveLineItem::call(
        transaction_id: transaction.id,
        product_id: "some-product-id",
        user: Users::SessionUser.new(transaction.user.id)
      )
    end
  end

  test "Should raise if the transaction belongs to another user" do
    # Arrange
    transaction = create(:transaction)
    line_item = create(:transaction_line_item, owner_transaction: transaction)

    # Act & Assert
    assert_raise NotFoundError do
      Transactions::RemoveLineItem::call(
        transaction_id: transaction.id,
        product_id: line_item.product_id,
        user: Users::SessionUser.new("some-user")
      )
    end
  end
end
