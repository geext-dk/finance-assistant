# frozen_string_literal: true

require "test_helper"

class TransactionsAddLineItemTest < ActiveSupport::TestCase
  test "Should add line item with per_piece product" do
    # Arrange
    transaction = create(:transaction)
    product = create(:product, user: transaction.user, quantity_type: 'per_piece')

    # Act
    result_transaction = Transactions::AddLineItem::call(
      user: Users::SessionUser.new(transaction.user.id),
      transaction_id: transaction.id,
      product_id: product.id,
      quantity: 3,
      price: 10,
      discounted_price: 8,
      total_price: 25)

    # Assert
    assert_equal transaction, result_transaction
    assert_equal 1, result_transaction.line_items.length

    result_line_item = result_transaction.line_items[0]
    assert_equal 3, result_line_item.quantity_pieces
    assert_nil result_line_item.quantity_weighted
    assert_equal 1000, result_line_item.price_cents
    assert_equal 800, result_line_item.discounted_price_cents
    assert_equal 2500, result_line_item.total_price_cents
  end

  test "Should add line item with weighted product" do
    # Arrange
    transaction = create(:transaction)
    product = create(:product, user: transaction.user, quantity_type: 'weighted')

    # Act
    result_transaction = Transactions::AddLineItem::call(
      user: Users::SessionUser.new(transaction.user.id),
      transaction_id: transaction.id,
      product_id: product.id,
      quantity: 2.5,
      price: 10,
      discounted_price: 8,
      total_price: 25)

    # Assert
    assert_equal transaction, result_transaction
    assert_equal 1, result_transaction.line_items.length

    result_line_item = result_transaction.line_items[0]
    assert_nil result_line_item.quantity_pieces
    assert_equal 2.5, result_line_item.quantity_weighted
    assert_equal 1000, result_line_item.price_cents
    assert_equal 800, result_line_item.discounted_price_cents
    assert_equal 2500, result_line_item.total_price_cents
  end

  test "Should truncate quantity if line item is per_piece" do
    # Arrange
    transaction = create(:transaction)
    product = create(:product, user: transaction.user, quantity_type: 'per_piece')

    # Act
    result_transaction = Transactions::AddLineItem::call(
      user: Users::SessionUser.new(transaction.user.id),
      transaction_id: transaction.id,
      product_id: product.id,
      quantity: 2.5,
      price: 10,
      discounted_price: 8,
      total_price: 25)

    # Assert
    result_line_item = result_transaction.line_items[0]
    assert_equal 2, result_line_item.quantity_pieces
    assert_nil result_line_item.quantity_weighted
  end

  test "Should add line item when discounted_price is not passed" do
    # Arrange
    transaction = create(:transaction)
    product = create(:product, user: transaction.user, quantity_type: 'per_piece')

    # Act & Assert
    assert_nothing_raised do
      Transactions::AddLineItem::call(
        user: Users::SessionUser.new(transaction.user.id),
        transaction_id: transaction.id,
        product_id: product.id,
        quantity: 2.5,
        price: 10,
        total_price: 25)
    end
  end

  test "Should throw if line item with same product already exists" do
    # Arrange
    transaction = create(:transaction)
    line_item = create(:transaction_line_item, owner_transaction: transaction)

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::AddLineItem::call(
        user: Users::SessionUser.new(transaction.user.id),
        transaction_id: transaction.id,
        product_id: line_item.product.id,
        quantity: 2.5,
        price: 10,
        discounted_price: 8,
        total_price: 25)
    end
  end

  test "Should throw if product belongs to another user" do
    # Arrange
    transaction = create(:transaction)

    another_user = create(:user)
    product = create(:product, user: another_user)

    # Act & Assert
    assert_raises NotFoundError do
      Transactions::AddLineItem::call(
        user: Users::SessionUser.new(transaction.user.id),
        transaction_id: transaction.id,
        product_id: product.id,
        quantity: 2.5,
        price: 10,
        discounted_price: 8,
        total_price: 25)
    end
  end

  test "Should throw if transaction belongs to another user" do
    # Arrange
    transaction = create(:transaction)
    product = create(:product, user: transaction.user)

    # Act & Assert
    assert_raises NotFoundError do
      Transactions::AddLineItem::call(
        user: Users::SessionUser.new("some-user"),
        transaction_id: transaction.id,
        product_id: product.id,
        quantity: 2.5,
        price: 10,
        discounted_price: 8,
        total_price: 25)
    end
  end

  test "Should throw if quantity is zero" do
    # Arrange
    transaction = create(:transaction)
    product = create(:product, user: transaction.user)

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::AddLineItem::call(
        user: Users::SessionUser.new(transaction.user.id),
        transaction_id: transaction.id,
        product_id: product.id,
        quantity: 0,
        price: 1,
        total_price: 2)
    end
  end

  test "Should throw if no price passed" do
    # Arrange
    transaction = create(:transaction)
    product = create(:product, user: transaction.user)

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::AddLineItem::call(
        user: Users::SessionUser.new(transaction.user.id),
        transaction_id: transaction.id,
        product_id: product.id,
        quantity: 1,
        price: nil,
        total_price: 1)
    end
  end

  test "Should throw if no total_price passed" do
    # Arrange
    transaction = create(:transaction)
    product = create(:product, user: transaction.user)

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::AddLineItem::call(
        user: Users::SessionUser.new(transaction.user.id),
        transaction_id: transaction.id,
        product_id: product.id,
        quantity: 1,
        price: 1,
        total_price: nil)
    end
  end

  test "Should correctly round" do
    # Arrange
    transaction = create(:transaction)
    product = create(:product, user: transaction.user)

    # Act
    result = Transactions::AddLineItem::call(
        user: Users::SessionUser.new(transaction.user.id),
        transaction_id: transaction.id,
        product_id: product.id,
        quantity: 1,
        price: 1190.37,
        total_price: 2)

    # Assert
    assert_equal result.line_items[0].price_cents, 119037
  end
end
