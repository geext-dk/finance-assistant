# frozen_string_literal: true

class BaseAuthorizedUserService < BaseApplicationService
  # @param [Users::SessionUser] user
  def initialize(user)
    @user = user
  end

  # Gets the current user
  #
  # @return [Users::SessionUser]
  def user
    @user
  end

  def self.call(*args, user:, **kwargs, &block)
    if user.nil?
      logger.warn "The user is not authorized to perform this operation (#{self.name})"
      raise ApplicationError.new("The user is not authorized to perform this operation")
    end

    new(*args, user: user, **kwargs, &block).call
  end
end
