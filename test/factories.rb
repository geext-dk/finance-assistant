# frozen_string_literal: true
require 'securerandom'

FactoryBot.define do
  factory :account do
    user
    sequence :name do |n|
      "Sample account #{n}"
    end
    currency { "SEK" }
    created_at { Time.now.utc }
    updated_at { Time.now.utc }
  end

  factory :product do
    user
    sequence :name do |n|
      "Sample product #{n}"
    end
    country { "SE" }
    quantity_type { "per_piece" }
    created_at { Time.now.utc }
    updated_at { Time.now.utc }
  end

  factory :merchant do
    user
    sequence :name do |n|
      "Sample merchant #{n}"
    end
    country { "SE" }
    created_at { Time.now.utc }
    updated_at { Time.now.utc }
  end

  factory :user do
    sequence :email do |n|
      "test_#{n}@example.com"
    end
    # password: somepassword
    password_digest { "$2a$04$gqTLyUNMMZAS2Rw.lCZ7Fu/LqkBv.iLpLZOPXYV.mMha6b9Bfrt42" }
  end

  factory :transaction do
    date { Time.now.utc }
    user
    account { association :account, user: user }
    merchant { association :merchant, user: user }
    country { merchant.country }
    currency { account.currency }
  end

  factory :transaction_line_item do
    owner_transaction factory: :transaction
    product { association :product, user: owner_transaction.user }
    sequence :quantity_pieces do |n|
      product.quantity_type == 'per_piece' ? 3 + n : nil
    end
    sequence :quantity_weighted do |n|
      product.quantity_type == 'weighted' ? 2.5 + n * 0.5 : nil
    end
    sequence :price_cents do |n|
      10000 + n + 1000
    end
    discounted_price_cents { price_cents * 0.8 }
    total_price_cents { (discounted_price_cents.nil? ? price_cents : discounted_price_cents) * (quantity_pieces || quantity_weighted) }
  end
end