# frozen_string_literal: true

class BaseRepository
  class << self
    # @param [String] id
    # @return [T]
    def get(id, user_id:, include_archived: false)
      wrap_errors do
        entity_query = query(include_archived: include_archived)

        if user_id
          entity_query = entity_query.where(user_id: user_id)
        end

        entity = entity_query.find_by(id: id)

        if entity
          entity
        else
          raise NotFoundError.new(id, type_name)
        end
      end
    end

    # @return [ActiveRecord::Relation<ApplicationRecord>]
    def list(user_id:, include_archived: false)
      query_all = query(include_archived: include_archived)

      user_id ? query_all.where(user_id: user_id) : query_all
    end

    def create(hash)
      wrap_errors do
        entity = record.new(hash)

        if entity.save
          entity
        else
          raise ApplicationError.new("Couldn't save #{type_name}", entity.errors.full_messages)
        end
      end
    end

    def update(entity, hash)
      wrap_errors do
        if entity.update(hash)
          entity
        else
          raise ApplicationError.new(
                  "Couldn't update #{type_name} with id '#{entity.id}'",
                  entity.errors.full_messages)
        end
      end
    end

    private

    # @return [Class<ApplicationRecord>]
    def record
      raise "Record was not defined"
    end

    # @return [String]
    def type_name
      raise "Type name was not defined"
    end

    # @return [ActiveRecord::Relation<ApplicationRecord>]
    def query(include_archived:)
      raise "No query defined"
    end

    def wrap_errors
      yield
    rescue ActiveRecord::ActiveRecordError => error
      raise ApplicationError.new("Unexpected error", [error.message])
    end
  end
end
