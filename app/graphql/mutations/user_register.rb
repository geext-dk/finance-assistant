# frozen_string_literal: true

module Mutations
  class UserRegister < BaseMutation
    null true
    argument :email, String
    argument :password, String
    argument :password_confirmation, String

    type Types::UserType

    def resolve(email:, password:, password_confirmation:)
      user = Users::Register.call(
        email: email,
        password: password,
        password_confirmation: password_confirmation)

      context[:current_user] = Users::SessionUser.new(user.id)

      user
    end
  end
end
