# frozen_string_literal: true


require "test_helper"

class UsersRegisterTest < ActiveSupport::TestCase
  test "Should register user" do
    # Arrange
    email = "some-email@test.com"
    password = "new-user-password"

    # Act
    result = Users::Register::call(email: email, password: password, password_confirmation: password)

    # Assert
    assert_equal email, result.email
    assert_not_empty result.id
    assert User.find(result.id).authenticate(password)
  end

  test "Should raise if email is in incorrect format" do
    # Arrange
    email = "some-incorrect-email"
    password = "new-user-password"

    # Act & Assert
    assert_raises ApplicationError do
      Users::Register::call(email: email, password: password, password_confirmation: password)
    end
  end
end
