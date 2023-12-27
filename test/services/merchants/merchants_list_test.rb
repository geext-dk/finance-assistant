# frozen_string_literal: true

require "test_helper"

class MerchantsListTest < ActiveSupport::TestCase
  test "Should get merchants list" do
    # Arrange
    user = create(:user)
    other_user = create(:user)

    merchants = create_list(:merchant, 5, user: user)
    create_list(:merchant, 4, user: user, archived_at: Time.now.utc)
    create_list(:merchant, 3, user: other_user)

    valid_merchant_ids = merchants.map { |a| a.id }

    # Act
    merchants = Merchants::List::call(user: Users::SessionUser.new(user.id))

    # Assert
    assert_equal 5, merchants.length
    assert_equal valid_merchant_ids.sort, merchants.map { |a| a.id }.sort
  end
end
