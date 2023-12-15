# frozen_string_literal: true

class NotFoundError < StandardError
  def initialize(id, type)
    super("Couldn't find #{type} with id '#{id}'")

    @id = id
    @type = type
  end
end