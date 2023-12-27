# frozen_string_literal: true

require "test_helper"

class AccountsListTest < ActiveSupport::TestCase
  test "Should get accounts list" do
    # Arrange
    user = create(:user)
    other_user = create(:user)

    accounts = create_list(:account, 5, user: user)
    create_list(:account, 4, user: user, archived_at: Time.now.utc)
    create_list(:account, 3, user: other_user)

    valid_account_ids = accounts.map { |a| a.id }

    # Act
    accounts = Accounts::List::call(user: Users::SessionUser.new(user.id))

    # Assert
    assert_equal 5, accounts.length
    assert_equal valid_account_ids, accounts.map { |a| a.id }
  end
end
