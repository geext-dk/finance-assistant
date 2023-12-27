# frozen_string_literal: true

require "test_helper"

class MerchantsGetByIdsTest < ActiveSupport::TestCase
  test "Should get merchants by ids" do
    # Arrange
    user = create(:user)
    other_user = create(:user)

    merchants = create_list(:merchant, 5, user: user)
    archived_merchants = create_list(:merchant, 5, user: user, archived_at: Time.now.utc)
    other_user_merchants = create_list(:merchant, 5, user: other_user)

    valid_merchant_ids = merchants.map { |a| a.id }

    merchant_ids = valid_merchant_ids.union(
      archived_merchants.map { |a| a.id },
      other_user_merchants.map { |a| a.id })


    # Act
    merchants = Merchants::GetByIds.call(merchant_ids: merchant_ids, user: Users::SessionUser.new(user.id))

    # Assert
    assert_equal valid_merchant_ids, merchants.map { |a| a.id }
  end
end
