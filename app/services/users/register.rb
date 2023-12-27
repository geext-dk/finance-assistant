# frozen_string_literal: true

module Users
  class Register < BaseApplicationService
    def initialize(email:, password:, password_confirmation:)
      @email = email
      @password = password
      @password_confirmation = password_confirmation
    end

    def call
      if User.exists?(email: @email)
        raise ApplicationError.new("A user with email '#{@email}' already exists")
      end

      user = User.create(email: @email, password: @password, password_confirmation: @password_confirmation)

      unless user.valid?
        raise ApplicationError.new("Couldn't create user", user.errors.full_messages)
      end

      UserDetails.new(
        id: user.id,
        email: user.email
      )
    end
  end
end
