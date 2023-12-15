# frozen_string_literal: true

module Types
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument

    def initialize(*args, anonymous: false, **kwargs, &block)
      @anonymous = anonymous
      super(*args, **kwargs, &block)
    end

    def authorized?(object, args, context)
      super && (@anonymous || context[:current_user])
    end
  end
end
