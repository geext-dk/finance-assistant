# frozen_string_literal: true

require "test_helper"

class AccountsArchiveTest < ActiveSupport::TestCase
  test "Should archive account by id" do
    # Arrange
    account = create(:account)

    # Act
    result = Accounts::Archive::call(account_id: account.id, user: Users::SessionUser.new(account.user.id))

    # Assert
    account = Account.find(account.id)
    assert_equal account, result
    assert_not_nil account.archived_at
  end

  test "Should throw if the account already archived" do
    # Arrange
    account = create(:account, archived_at: Time.now.utc)

    # Act & Assert
    assert_raises NotFoundError do
      Accounts::Archive::call(account_id: account.id, user: Users::SessionUser.new(account.user.id))
    end
  end

  test "Should throw if the account doesn't belong to the current user" do
    # Arrange
    account = create(:account)

    # Act & Assert
    assert_raises NotFoundError do
      Accounts::Archive::call(account_id: account.id, user: Users::SessionUser.new('some-user'))
    end
  end
end
