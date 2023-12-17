# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test "Should be valid when fields are defined" do
    # Arrange
    product = create_valid_product

    # Act
    valid = product.valid?

    # Assert
    assert valid
  end

  test "Should validate all required fields and associations" do
    # Arrange
    product = Product.new

    # Act
    valid = product.valid?

    # Assert
    assert_not valid
    assert_includes product.errors[:user], "must exist"
    assert_includes product.errors[:name], "can't be blank"
    assert_includes product.errors[:quantity_type], "can't be blank"
    assert_includes product.errors[:country], "can't be blank"
  end

  test "Should not accept invalid quantity_type value" do
    # Arrange
    product = create_valid_product

    # Act & Assert
    assert_raises ArgumentError do
      product.quantity_type = :hello
    end
  end

  test "Should validate country" do
    # Arrange
    product = create_valid_product

    product.country = "invalid-country"

    # Act
    valid = product.valid?

    # Assert
    assert_not valid
    assert_includes product.errors[:country], "is invalid"
  end

  def create_valid_product
    product = Product.new(
      user_id: 'user-id',
      name: 'Name',
      quantity_type: 'per_piece',
      country: 'SE'
    )

    product.user = User.new

    product
  end
end
