# frozen_string_literal: true
require "test_helper"

class ProductsGetTest < ActiveSupport::TestCase
  test "Should get product" do
    # Arrange
    product = create(:product)

    # Act
    result = Products::Get::call(product_id: product.id, user: Users::SessionUser.new(product.user.id))

    # Assert
    assert_equal product.id, result.id
    assert_equal product.name, result.name
    assert_equal product.country, result.country
    assert_equal product.quantity_type, result.quantity_type
  end

  test "Should throw if the product is archived" do
    # Arrange
    product = create(:product, archived_at: Time.now.utc)

    # Act & Assert
    assert_raises NotFoundError do
      Products::Get::call(product_id: product.id, user: Users::SessionUser.new(product.user.id))
    end
  end

  test "Should throw if the product belongs to another user" do
    # Arrange
    product = create(:product)

    # Act & Assert
    assert_raises NotFoundError do
      Products::Get::call(product_id: product.id, user: Users::SessionUser.new("some-user"))
    end
  end
end
