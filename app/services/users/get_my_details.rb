# frozen_string_literal: true

module Users
  class GetMyDetails < BaseAuthorizedUserService
    def initialize(user:)
      super(user)
    end

    def call
      new_user = capture_not_found(user.id, Constants::USER_TYPE_NAME) { User.find(user.id) }

      UserDetails.new(
        id: new_user.id,
        email: new_user.email
      )
    end
  end
end
