# frozen_string_literal: true

module Merchants
  class List < BaseAuthorizedUserService
    def initialize(user:)
      super(user)
    end
    def call
      Merchants::Repository.list(user_id: user.id)
    end
  end
end
