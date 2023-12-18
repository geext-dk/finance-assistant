# frozen_string_literal: true

module Archivable
  extend ActiveSupport::Concern

  included do
    scope :existing, -> { where(archived_at: nil) }
  end

  def archive
    update({ archived_at: Time.now.utc })
  end
end
