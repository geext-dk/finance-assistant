# frozen_string_literal: true

require "test_helper"

class TransactionsUpdateLineItemTest < ActiveSupport::TestCase
  test "Should update line item" do
    # Arrange
    sample_transaction = create(:transaction)
    sample_line_item = create(:transaction_line_item, owner_transaction: sample_transaction)

    # Act
    transaction = Transactions::UpdateLineItem::call(
      user: Users::SessionUser.new(sample_transaction.user.id),
      transaction_id: sample_transaction.id,
      product_id: sample_line_item.product_id,
      quantity: 7,
      price: 30,
      discounted_price: 27,
      total_price: 55
    )

    # Assert
    assert_equal sample_transaction, transaction
    line_item = transaction.line_items.find { |li| li.product_id == sample_line_item.product_id }
    assert_equal 7, line_item.quantity_pieces
    assert_equal 3000, line_item.price_cents
    assert_equal 2700, line_item.discounted_price_cents
    assert_equal 5500, line_item.total_price_cents
  end

  test "Should raise if transaction was not found" do
    assert_raises NotFoundError do
      Transactions::UpdateLineItem::call(
        user: Users::SessionUser.new("some-user"),
        transaction_id: "some-transaction",
        product_id: "some-product",
        quantity: 7,
        price: 30,
        discounted_price: 27,
        total_price: 55
      )
    end
  end

  test "Should raise if line item was not found" do
    # Arrange
    sample_transaction = create(:transaction)
    create(:transaction_line_item, owner_transaction: sample_transaction)

    # Act & Assert
    assert_raises NotFoundError do
      Transactions::UpdateLineItem::call(
        user: Users::SessionUser.new(sample_transaction.user.id),
        transaction_id: sample_transaction.id,
        product_id: "some-product",
        quantity: 7,
        price: 30,
        discounted_price: 27,
        total_price: 55
      )
    end
  end

  test "Should raise if transaction belongs to another user" do
    # Arrange
    sample_transaction = create(:transaction)
    line_item = create(:transaction_line_item, owner_transaction: sample_transaction)

    # Act & Assert
    assert_raises NotFoundError do
      Transactions::UpdateLineItem::call(
        user: Users::SessionUser.new("some-user"),
        transaction_id: sample_transaction.id,
        product_id: line_item.product_id,
        quantity: 7,
        price: 30,
        discounted_price: 27,
        total_price: 55
      )
    end
  end

  test "Should raise if quantity is not more than zero" do
    # Arrange
    sample_transaction = create(:transaction)
    line_item = create(:transaction_line_item, owner_transaction: sample_transaction)

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::UpdateLineItem::call(
        user: Users::SessionUser.new(sample_transaction.user.id),
        transaction_id: sample_transaction.id,
        product_id: line_item.product_id,
        quantity: 0,
        price: 30,
        discounted_price: 27,
        total_price: 55
      )
    end
  end

  test "Should raise if price is not passed" do
    # Arrange
    sample_transaction = create(:transaction)
    line_item = create(:transaction_line_item, owner_transaction: sample_transaction)

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::UpdateLineItem::call(
        user: Users::SessionUser.new(sample_transaction.user.id),
        transaction_id: sample_transaction.id,
        product_id: line_item.product_id,
        quantity: 7,
        price: nil,
        discounted_price: 27,
        total_price: 55
      )
    end
  end

  test "Should raise if total_price is not passed" do
    # Arrange
    sample_transaction = create(:transaction)
    line_item = create(:transaction_line_item, owner_transaction: sample_transaction)

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::UpdateLineItem::call(
        user: Users::SessionUser.new(sample_transaction.user.id),
        transaction_id: sample_transaction.id,
        product_id: line_item.product_id,
        quantity: 7,
        price: 30,
        discounted_price: 27,
        total_price: nil
      )
    end
  end
end
