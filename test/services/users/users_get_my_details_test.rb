# frozen_string_literal: true

require "test_helper"

class UsersGetMyDetailsTest < ActiveSupport::TestCase
  test "Should return current user info" do
    # Arrange
    user = create(:user)

    # Act
    result = Users::GetMyDetails::call(user: Users::SessionUser.new(user.id))

    # Assert
    assert_equal user.id, result.id
    assert_equal user.email, result.email
  end

  test "Should raise if current user is unknown" do
    assert_raises ApplicationError do
      Users::GetMyDetails::call(user: Users::SessionUser.new(nil))
    end
  end
end
