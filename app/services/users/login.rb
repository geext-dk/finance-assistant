# frozen_string_literal: true

module Users
  class Login < BaseApplicationService
    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.find_by(email: @email)&.authenticate(@password)

      unless user
        raise ApplicationError.new("Couldn't authenticate user '#{@email}''")
      end

      user
    end
  end
end
