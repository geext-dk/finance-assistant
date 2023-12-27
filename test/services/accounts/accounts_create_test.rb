# frozen_string_literal: true

require "test_helper"

class AccountsCreateTest < ActiveSupport::TestCase
  test "Should create an account" do
    # Arrange
    user = create(:user)

    # Act
    result = Accounts::Create::call(name: "Name", currency: "SEK", user: Users::SessionUser.new(user.id))

    # Assert
    account = Account.find(result.id)
    assert_equal result, account
    assert_equal "Name", account.name
    assert_equal "SEK", account.currency
    assert_equal user.id, account.user_id
    assert_nil account.archived_at
  end

  test "Should throw when invalid data passed" do
    # Arrange
    user = create(:user)

    # Act & Assert
    assert_raises ApplicationError do
      Accounts::Create::call(name: "", currency: "SEK", user: Users::SessionUser.new(user.id))
    end
  end
end
