# frozen_string_literal: true

require "test_helper"

class ProductsCreateTest < ActiveSupport::TestCase
  test "Should create a product" do
    # Arrange
    user = create(:user)

    # Act
    result = Products::Create::call(name: "Name", country: "SE", quantity_type: "weighted", user: Users::SessionUser.new(user.id))

    # Assert
    product = Product.find(result.id)
    assert_equal result, product
    assert_equal "Name", product.name
    assert_equal "SE", product.country
    assert_equal "weighted", product.quantity_type
    assert_equal user.id, product.user_id
    assert_nil product.archived_at
  end

  test "Should throw when invalid name passed" do
    # Arrange
    user = create(:user)

    # Act & Assert
    assert_raises ApplicationError do
      Products::Create::call(name: "", country: "SE", quantity_type: "weighted", user: Users::SessionUser.new(user.id))
    end
  end

  test "Should throw when invalid country passed" do
    # Arrange
    user = create(:user)

    # Act & Assert
    assert_raises ApplicationError do
      Products::Create::call(name: "Product name", country: "invalid", quantity_type: "weighted", user: Users::SessionUser.new(user.id))
    end
  end

  test "Should throw when invalid quantity type passed" do
    # Arrange
    user = create(:user)

    # Act & Assert
    assert_raises ArgumentError do
      Products::Create::call(name: "Product name", country: "SE", quantity_type: "invalid", user: Users::SessionUser.new(user.id))
    end
  end
end
