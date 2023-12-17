# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Should be valid when fields are defined" do
    # Arrange
    user = create_valid_user

    # Act
    valid = user.valid?

    # Assert
    assert valid
  end

  test "Should validate email" do
    # Arrange
    user = create_valid_user
    user.email = "invalid-email"

    # Act
    valid = user.valid?

    # Assert
    assert_not valid
    assert_includes user.errors[:email], "is invalid"
  end

  def create_valid_user
    User.new(id: "id", email: "test@example", password: "x")
  end
end
