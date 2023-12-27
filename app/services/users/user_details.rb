# frozen_string_literal: true

module Users
  class UserDetails
    def initialize(id:, email:)
      @id = id
      @email = email
    end

    attr_reader :id, :email
  end
end
