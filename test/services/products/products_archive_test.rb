# frozen_string_literal: true

require "test_helper"

class ProductsArchiveTest < ActiveSupport::TestCase
  test "Should archive product by id" do
    # Arrange
    product = create(:product)

    # Act
    result = Products::Archive::call(product_id: product.id, user: Users::SessionUser.new(product.user.id))

    # Assert
    product = Product.find(product.id)
    assert_equal product, result
    assert_not_nil product.archived_at
  end

  test "Should throw if the product already archived" do
    # Arrange
    product = create(:product, archived_at: Time.now.utc)

    # Act & Assert
    assert_raises NotFoundError do
      Products::Archive::call(product_id: product.id, user: Users::SessionUser.new(product.user.id))
    end
  end

  test "Should throw if the product doesn't belong to the current user" do
    # Arrange
    product = create(:product)

    # Act & Assert
    assert_raises NotFoundError do
      Products::Archive::call(product_id: product.id, user: Users::SessionUser.new('some-user'))
    end
  end
end
