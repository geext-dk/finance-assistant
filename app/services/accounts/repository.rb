# frozen_string_literal: true

module Accounts
  class Repository < BaseRepository
    class << self
      private

      # @return [ActiveRecord::Relation<Account>]
      def query(include_archived:)
        include_archived ? Account.all : Account.where(archived_at: nil)
      end

      def type_name
        Accounts::Constants::ACCOUNT_TYPE_NAME
      end

      # @return [Class<Account>]
      def record
        Account
      end
    end
  end
end
