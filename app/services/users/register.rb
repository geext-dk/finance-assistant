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

      User.create(email: @email, password: @password, password_confirmation: @password_confirmation)
    end
  end
end
