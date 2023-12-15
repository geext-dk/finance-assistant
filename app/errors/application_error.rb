# frozen_string_literal: true

class ApplicationError < StandardError
  def initialize(msg, errors = [])
    super(msg)

    @errors = errors
  end

  def errors
    @errors
  end
end
