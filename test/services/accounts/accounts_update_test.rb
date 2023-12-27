# frozen_string_literal: true

require "test_helper"

class AccountsUpdateTest < ActiveSupport::TestCase
  test "Should update account" do
    # Arrange
    account = create(:account)

    # Act
    result = Accounts::Update::call(account_id: account.id, name: "New name", user: Users::SessionUser.new(account.user.id))

    # Assert
    account = Account.find(account.id)
    assert_equal account, result
    assert_equal "New name", result.name
  end

  test "Should throw if the account is archived" do
    # Arrange
    account = create(:account, archived_at: Time.now.utc)

    # Act & Assert
    assert_raises NotFoundError do
      Accounts::Update::call(account_id: account.id, name: "New name", user: Users::SessionUser.new(account.user.id))
    end
  end

  test "Should throw if the account belongs to another user" do
    # Arrange
    account = create(:account)

    # Act & Assert
    assert_raises NotFoundError do
      Accounts::Update::call(account_id: account.id, name: "New name", user: Users::SessionUser.new('another-user'))
    end
  end

  test "Should throw if the input data is invalid" do
    # Arrange
    account = create(:account)

    # Act & Assert
    assert_raises ApplicationError do
      Accounts::Update::call(account_id: account.id, name: "", user: Users::SessionUser.new(account.user.id))
    end
  end
end
