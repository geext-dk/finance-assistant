# frozen_string_literal: true

class FinanceAssistantSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader

  # GraphQL-Ruby calls this when something goes wrong while running a query:
  def self.type_error(err, context)
    # if err.is_a?(GraphQL::InvalidNullError)
    #   # report to your bug tracker here
    #   return nil
    # end
    super
  end

  # Union and Interface Resolution
  def self.resolve_type(abstract_type, obj, ctx)
    # TODO: Implement this method
    # to return the correct GraphQL object type for `obj`
    raise(GraphQL::RequiredImplementationMissingError)
  end

  # Stop validating when it encounters this many errors:
  validate_max_errors(100)

  # Override this hook to handle cases when `authorized?` returns false for a field:
  def self.unauthorized_field(error)
    # Add a top-level error to the response instead of returning nil:
    raise GraphQL::ExecutionError, "The field #{error.field.graphql_name} on an object of type #{error.type.graphql_name} was hidden due to permissions"
  end

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    object.to_gid_param
  end

  # Given a string UUID, find the object
  def self.object_from_id(global_id, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    GlobalID.find(global_id)
  end

  rescue_from NotFoundError do |err, obj, args, ctx, field|
    raise GraphQL::ExecutionError, err.message
  end

  rescue_from ApplicationError do |err, obj, args, ctx, field|
    err.errors.each do |error|
      # TODO test, it doesn't look like it works
      ctx.add_error GraphQL::ExecutionError.new(error)
    end

    raise GraphQL::ExecutionError, err.message
  end
end
