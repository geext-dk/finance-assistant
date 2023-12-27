# frozen_string_literal: true

require "test_helper"

class ProductsGetByIdsTest < ActiveSupport::TestCase
  test "Should get products by ids" do
    # Arrange
    user = create(:user)
    other_user = create(:user)

    products = create_list(:product, 5, user: user)
    archived_products = create_list(:product, 5, user: user, archived_at: Time.now.utc)
    other_user_products = create_list(:product, 5, user: other_user)

    valid_product_ids = products.map { |a| a.id }

    product_ids = valid_product_ids.union(
      archived_products.map { |a| a.id },
      other_user_products.map { |a| a.id })


    # Act
    products = Products::GetByIds.call(product_ids: product_ids, user: Users::SessionUser.new(user.id))

    # Assert
    assert_equal valid_product_ids.sort, products.map { |a| a.id }.sort
  end
end
