# frozen_string_literal: true

# TODO different exceptions for: Unauthorized, Unauthenticated, ArgumentError, etc
class ApplicationError < StandardError
  def initialize(msg, errors = [])
    super(msg)

    @errors = errors
  end

  def errors
    @errors
  end
end
