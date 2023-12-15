# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_account, mutation: Mutations::AccountCreate
    field :update_account, mutation: Mutations::AccountUpdate
    field :archive_account, mutation: Mutations::AccountArchive

    field :create_product, mutation: Mutations::ProductCreate
    field :update_product, mutation: Mutations::ProductUpdate
    field :archive_product, mutation: Mutations::ProductArchive

    field :create_merchant, mutation: Mutations::MerchantCreate
    field :update_merchant, mutation: Mutations::MerchantUpdate
    field :archive_merchant, mutation: Mutations::MerchantArchive

    field :create_transaction, mutation: Mutations::TransactionCreate
    field :update_transaction, mutation: Mutations::TransactionUpdate
    field :add_transaction_line_item, mutation: Mutations::TransactionAddLineItem
    field :update_transaction_line_item, mutation: Mutations::TransactionUpdateLineItem
    field :remove_transaction_line_item, mutation: Mutations::TransactionRemoveLineItem

    field :login, mutation: Mutations::UserLogin, anonymous: true
    field :register, mutation: Mutations::UserRegister, anonymous: true
  end
end
