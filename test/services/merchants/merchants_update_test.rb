# frozen_string_literal: true

require "test_helper"

class MerchantsUpdateTest < ActiveSupport::TestCase
  test "Should update merchant" do
    # Arrange
    merchant = create(:merchant)

    # Act
    result = Merchants::Update::call(merchant_id: merchant.id, name: "New name", user: Users::SessionUser.new(merchant.user.id))

    # Assert
    merchant = Merchant.find(merchant.id)
    assert_equal merchant, result
    assert_equal "New name", result.name
  end

  test "Should throw if the merchant is archived" do
    # Arrange
    merchant = create(:merchant, archived_at: Time.now.utc)

    # Act & Assert
    assert_raises NotFoundError do
      Merchants::Update::call(merchant_id: merchant.id, name: "New name", user: Users::SessionUser.new(merchant.user.id))
    end
  end

  test "Should throw if the merchant belongs to another user" do
    # Arrange
    merchant = create(:merchant)

    # Act & Assert
    assert_raises NotFoundError do
      Merchants::Update::call(merchant_id: merchant.id, name: "New name", user: Users::SessionUser.new('another-user'))
    end
  end

  test "Should throw if the input data is invalid" do
    # Arrange
    merchant = create(:merchant)

    # Act & Assert
    assert_raises ApplicationError do
      Merchants::Update::call(merchant_id: merchant.id, name: "", user: Users::SessionUser.new(merchant.user.id))
    end
  end
end
