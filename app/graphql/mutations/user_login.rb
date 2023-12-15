# frozen_string_literal: true

module Mutations
  class UserLogin < BaseMutation
    null true
    argument :email, String
    argument :password, String

    type Types::UserType

    def resolve(email:, password:)
      user = Users::Login.call(email: email, password: password)

      context[:current_user] = Users::SessionUser.new(user.id)

      user
    end
  end
end
