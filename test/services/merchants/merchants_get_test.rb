# frozen_string_literal: true
require "test_helper"

class MerchantsGetTest < ActiveSupport::TestCase
  test "Should get merchant" do
    # Arrange
    merchant = create(:merchant)

    # Act
    result = Merchants::Get::call(merchant_id: merchant.id, user: Users::SessionUser.new(merchant.user.id))

    # Assert
    assert_equal merchant.id, result.id
    assert_equal merchant.name, result.name
    assert_equal merchant.country, result.country
  end

  test "Should throw if the merchant is archived" do
    # Arrange
    merchant = create(:merchant, archived_at: Time.now.utc)

    # Act & Assert
    assert_raises NotFoundError do
      Merchants::Get::call(merchant_id: merchant.id, user: Users::SessionUser.new(merchant.user.id))
    end
  end

  test "Should throw if the merchant belongs to another user" do
    # Arrange
    merchant = create(:merchant)

    # Act & Assert
    assert_raises NotFoundError do
      Merchants::Get::call(merchant_id: merchant.id, user: Users::SessionUser.new("some-user"))
    end
  end
end
