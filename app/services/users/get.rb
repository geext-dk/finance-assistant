# frozen_string_literal: true

module Users
  class Get
    def initialize(user_id:)
      @user_id = user_id
    end

    def call
      Repository::get(@user_id, user_id: nil)
    end
  end
end
