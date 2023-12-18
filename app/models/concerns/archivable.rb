# frozen_string_literal: true

module Archivable
  extend ActiveSupport::Concern

  included do
    scope :existing, -> { where(archived_at: nil) }
    scope :with_archived, ->(with_archived) { where(archived_at: nil) unless with_archived }
  end

  def archive
    update({ archived_at: Time.now.utc })
  end
end
