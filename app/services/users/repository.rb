# frozen_string_literal: true

module Users
  class Repository < BaseRepository
    class << self
      # @return [Class<User>]
      def record
        User
      end

      # @return [String]
      def type_name
        Constants::USER_TYPE_NAME
      end

      # @return [ActiveRecord::Relation<ApplicationRecord>]
      def query(include_archived:)
        User.all
      end
    end
  end
end
