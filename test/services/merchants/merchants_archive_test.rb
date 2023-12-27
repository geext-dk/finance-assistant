# frozen_string_literal: true

require "test_helper"

class MerchantsArchiveTest < ActiveSupport::TestCase
  test "Should archive merchant by id" do
    # Arrange
    merchant = create(:merchant)

    # Act
    result = Merchants::Archive::call(merchant_id: merchant.id, user: Users::SessionUser.new(merchant.user.id))

    # Assert
    merchant = Merchant.find(merchant.id)
    assert_equal merchant, result
    assert_not_nil merchant.archived_at
  end

  test "Should throw if the merchant already archived" do
    # Arrange
    merchant = create(:merchant, archived_at: Time.now.utc)

    # Act & Assert
    assert_raises NotFoundError do
      Merchants::Archive::call(merchant_id: merchant.id, user: Users::SessionUser.new(merchant.user.id))
    end
  end

  test "Should throw if the merchant doesn't belong to the current user" do
    # Arrange
    merchant = create(:merchant)

    # Act & Assert
    assert_raises NotFoundError do
      Merchants::Archive::call(merchant_id: merchant.id, user: Users::SessionUser.new('some-user'))
    end
  end
end
