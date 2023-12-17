# frozen_string_literal: true

require "test_helper"

class MerchantTest < ActiveSupport::TestCase
  test "Should be valid when fields are defined" do
    # Arrange
    merchant = create_valid_merchant

    # Act
    valid = merchant.valid?

    # Assert
    assert valid
  end

  test "Should validate all required fields and associations" do
    # Arrange
    merchant = Merchant.new

    # Act
    valid = merchant.valid?

    # Assert
    assert_not valid
    assert_includes merchant.errors[:user], "must exist"
    assert_includes merchant.errors[:name], "can't be blank"
    assert_includes merchant.errors[:country], "can't be blank"
  end

  test "Should validate country" do
    # Arrange
    merchant = create_valid_merchant

    merchant.country = "invalid-country"

    # Act
    valid = merchant.valid?

    # Assert
    assert_not valid
    assert_includes merchant.errors[:country], "is invalid"
  end

  def create_valid_merchant
    merchant = Merchant.new(
      user_id: 'user-id',
      name: 'Name',
      country: 'SE'
    )

    merchant.user = User.new

    merchant
  end
end
