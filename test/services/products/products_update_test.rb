# frozen_string_literal: true

require "test_helper"

class ProductsUpdateTest < ActiveSupport::TestCase
  test "Should update product" do
    # Arrange
    product = create(:product)

    # Act
    result = Products::Update::call(product_id: product.id, name: "New name", user: Users::SessionUser.new(product.user.id))

    # Assert
    product = Product.find(product.id)
    assert_equal product, result
    assert_equal "New name", result.name
  end

  test "Should throw if the product is archived" do
    # Arrange
    product = create(:product, archived_at: Time.now.utc)

    # Act & Assert
    assert_raises NotFoundError do
      Products::Update::call(product_id: product.id, name: "New name", user: Users::SessionUser.new(product.user.id))
    end
  end

  test "Should throw if the product belongs to another user" do
    # Arrange
    product = create(:product)

    # Act & Assert
    assert_raises NotFoundError do
      Products::Update::call(product_id: product.id, name: "New name", user: Users::SessionUser.new('another-user'))
    end
  end

  test "Should throw if the input data is invalid" do
    # Arrange
    product = create(:product)

    # Act & Assert
    assert_raises ApplicationError do
      Products::Update::call(product_id: product.id, name: "", user: Users::SessionUser.new(product.user.id))
    end
  end
end
