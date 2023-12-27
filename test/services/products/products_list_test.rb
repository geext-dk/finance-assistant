# frozen_string_literal: true

require "test_helper"

class ProductsListTest < ActiveSupport::TestCase
  test "Should get products list" do
    # Arrange
    user = create(:user)
    other_user = create(:user)

    products = create_list(:product, 5, user: user)
    create_list(:product, 4, user: user, archived_at: Time.now.utc)
    create_list(:product, 3, user: other_user)

    valid_product_ids = products.map { |a| a.id }

    # Act
    products = Products::List::call(user: Users::SessionUser.new(user.id))

    # Assert
    assert_equal 5, products.length
    assert_equal valid_product_ids, products.map { |a| a.id }
  end
end
