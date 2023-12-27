# frozen_string_literal: true

require "test_helper"

class UsersAuthenticateTest < ActiveSupport::TestCase
  test "Should authenticate" do
    # Arrange
    user = create(:user)

    # Act
    result = Users::Authenticate::call(email: user.email, password: "somepassword")

    # Assert
    assert_equal user.id, result.id
    assert_equal user.email, result.email
  end

  test "Should raise when password is incorrect" do
    # Arrange
    user = create(:user)

    # Act & Assert
    assert_raises ApplicationError do
      Users::Authenticate::call(email: user.email, password: "incorrect-password")
    end
  end

  test "Should raise when user was not found" do
    assert_raises ApplicationError do
      Users::Authenticate::call(email: 'unknown-email', password: "somepassword")
    end
  end
end
