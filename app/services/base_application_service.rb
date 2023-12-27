# frozen_string_literal: true

class BaseApplicationService
  include ActiveModel::Validations

  def initialize(*args, **kwargs, &block)
  end

  def self.call(*args, **kwargs, &block)
    obj = new(*args, **kwargs, &block)

    unless obj.valid?
      raise ApplicationError.new("Validation error", obj.errors.full_messages)
    end

    obj.call
  rescue ActiveRecord::ActiveRecordError => error
    raise ApplicationError.new("Unexpected error", [error.message])
  end

  def call
    raise NotImplementedError("ApplicationService call method was not implemented")
  end

  def logger
    self.class.logger
  end

  def self.logger
    Rails.logger
  end

  def capture_not_found(id, type_name)
    yield
  rescue ActiveRecord::RecordNotFound
    raise NotFoundError.new(id, type_name)
  end
end
