# frozen_string_literal: true

module Users
  class Authenticate < BaseApplicationService
    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.find_by(email: @email)&.authenticate(@password)

      unless user
        raise ApplicationError.new("Couldn't authenticate user '#{@email}''")
      end

      UserDetails.new(
        id: user.id,
        email: user.email
      )
    end
  end
end
