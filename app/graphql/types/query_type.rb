# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ID], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :account, AccountType, "Find an account by ID" do
      argument :id, ID
    end
    def account(id:)
      Accounts::Get.call(account_id: id, user: current_user)
    end

    field :accounts, AccountType.connection_type, "Get accounts list"
    def accounts
      Accounts::List.call(user: current_user)
    end

    field :product, ProductType, "Find a product by ID" do
      argument :id, ID
    end
    def product(id:)
      Products::Get.call(product_id: id, user: current_user)
    end

    field :products, ProductType.connection_type, "Get products list"
    def products
      Products::List.call(user: current_user)
    end

    field :merchant, MerchantType, "Find a merchant by ID" do
      argument :id, ID
    end
    def merchant(id:)
      Merchants::Get.call(merchant_id: id, user: current_user)
    end

    field :merchants, MerchantType.connection_type, "Get merchants list"
    def merchants
      Merchants::List.call(user: current_user)
    end

    field :transaction, TransactionType, "Find a transaction by ID" do
      argument :id, ID
    end
    def transaction(id:)
      Transactions::Get.call(transaction_id: id, user: current_user)
    end

    field :transactions, TransactionType.connection_type, "Get transactions list"
    def transactions
      Transactions::List.call(user: current_user)
    end

    private

    def current_user
      context[:current_user]
    end
  end
end
