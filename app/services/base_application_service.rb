# frozen_string_literal: true

class BaseApplicationService
  def initialize(*args, **kwargs, &block)
  end

  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs, &block).call
  end

  def call
    raise NotImplementedError("ApplicationService call method was not implemented")
  end

  def logger
    Rails.logger
  end
end
