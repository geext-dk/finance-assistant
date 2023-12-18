# frozen_string_literal: true

module Users
  class Get < BaseAuthorizedUserService
    def initialize(user_id:)
      @user_id = user_id
    end

    def call
      capture_not_found(@user_id, Constants::USER_TYPE_NAME) { User.find(@user_id) }
    end
  end
end
