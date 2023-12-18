# frozen_string_literal: true

module UserOwned
  extend ActiveSupport::Concern

  included do
    scope :for_user, ->(user_id) { where(user_id: user_id) }
  end
end
