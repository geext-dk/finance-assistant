# frozen_string_literal: true

require "test_helper"

class MerchantsCreateTest < ActiveSupport::TestCase
  test "Should create a merchant" do
    # Arrange
    user = create(:user)

    # Act
    result = Merchants::Create::call(name: "Name", country: "SE", user: Users::SessionUser.new(user.id))

    # Assert
    merchant = Merchant.find(result.id)
    assert_equal result, merchant
    assert_equal "Name", merchant.name
    assert_equal "SE", merchant.country
    assert_equal user.id, merchant.user_id
    assert_nil merchant.archived_at
  end

  test "Should throw when invalid name passed" do
    # Arrange
    user = create(:user)

    # Act & Assert
    assert_raises ApplicationError do
      Merchants::Create::call(name: "", country: "SE", user: Users::SessionUser.new(user.id))
    end
  end

  test "Should throw when invalid country passed" do
    # Arrange
    user = create(:user)

    # Act & Assert
    assert_raises ApplicationError do
      Merchants::Create::call(name: "Name", country: "invalid-country", user: Users::SessionUser.new(user.id))
    end
  end
end
