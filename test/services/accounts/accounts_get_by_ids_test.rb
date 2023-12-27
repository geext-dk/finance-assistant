# frozen_string_literal: true

require "test_helper"

class AccountsGetByIdsTest < ActiveSupport::TestCase
  test "Should get accounts by ids" do
    # Arrange
    user = create(:user)
    other_user = create(:user)

    accounts = create_list(:account, 5, user: user)
    archived_accounts = create_list(:account, 5, user: user, archived_at: Time.now.utc)
    other_user_accounts = create_list(:account, 5, user: other_user)

    valid_account_ids = accounts.map { |a| a.id }

    account_ids = valid_account_ids.union(
      archived_accounts.map { |a| a.id },
      other_user_accounts.map { |a| a.id })


    # Act
    accounts = Accounts::GetByIds.call(account_ids: account_ids, user: Users::SessionUser.new(user.id))

    # Assert
    assert_equal valid_account_ids, accounts.map { |a| a.id }
  end
end
