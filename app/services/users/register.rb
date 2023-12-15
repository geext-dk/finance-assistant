# frozen_string_literal: true

module Users
  class Register < BaseApplicationService
    def initialize(email:, password:, password_confirmation:)
      @email = email
      @password = password
      @password_confirmation = password_confirmation
    end

    def call
      existing_user = User.find_by(email: @email)

      if existing_user
        raise ApplicationError.new("A user with email '#{@email}' already exists")
      end

      Repository::create(email: @email, password: @password, password_confirmation: @password_confirmation)
    end
  end
end
