require "test_helper"

CREATE_TRANSACTION_MUTATION = '
mutation createTransactionMutation($accountId: ID!, $merchantId: ID!, $date: ISO8601DateTime!) {
  createTransaction(input: { accountId: $accountId, merchantId: $merchantId, date: $date }) {
    id
    date
    country
    currency
    accountId
    merchantId
  }
}'

GET_TRANSACTION_QUERY = '
query getTransactionQuery($id: ID!) {
  transaction(id: $id) {
    id
    date
    country
    currency
    accountId
    merchantId
    lineItems {
      productId
      quantity
      price
      discountedPrice
      totalPrice
    }
  }
}'

GET_TRANSACTIONS_LIST_QUERY = '
query getTransactionsListQuery {
  transactions {
    nodes {
      id
      date
      country
      currency
      accountId
      merchantId
      lineItems {
        productId
        quantity
        price
        discountedPrice
        totalPrice
      }
    }
  }
}'

GET_TRANSACTIONS_LIST_QUERY_REFERENCED_OBJECTS = '
query getTransactionsListQueryExtended {
  transactions {
    nodes {
      id
      account {
        id
        name
        currency
      }
      merchant {
        id
        name
        country
      }
      lineItems {
        productId
        product {
          id
          name
          country
          quantityType
        }
      }
    }
  }
}'

UPDATE_TRANSACTION_MUTATION = '
mutation updateTransactionMutation($id: ID!, $new_date: ISO8601DateTime!) {
  updateTransaction(input: { transactionId: $id, date: $new_date }) {
    id
    date
    country
    currency
    accountId
    merchantId
  }
}'

ADD_LINE_ITEM_MUTATION = '
mutation addLineItemMutation(
  $transactionId: ID!,
  $productId: ID!,
  $quantity: Float!,
  $price: Float!,
  $discountedPrice: Float,
  $totalPrice: Float!) {
  addTransactionLineItem(input: {
    transactionId: $transactionId,
    productId: $productId,
    quantity: $quantity,
    price: $price,
    discountedPrice: $discountedPrice,
    totalPrice: $totalPrice
  }) {
    id
    date
    country
    currency
    accountId
    merchantId
    lineItems {
      productId
      quantity
      price
      discountedPrice
      totalPrice
    }
  }
}'

UPDATE_LINE_ITEM_MUTATION = '
mutation updateLineItemMutation(
  $transactionId: ID!,
  $productId: ID!,
  $quantity: Float!,
  $price: Float!,
  $discountedPrice: Float,
  $totalPrice: Float!) {
  updateTransactionLineItem(input: {
    transactionId: $transactionId,
    productId: $productId,
    quantity: $quantity,
    price: $price,
    discountedPrice: $discountedPrice,
    totalPrice: $totalPrice
  }) {
    id
    date
    country
    currency
    accountId
    merchantId
    lineItems {
      productId
      quantity
      price
      discountedPrice
      totalPrice
    }
  }
}'

REMOVE_LINE_ITEM_MUTATION = '
mutation removeLineItemMutation($transactionId: ID!, $productId: ID!) {
  removeTransactionLineItem(input: {
    transactionId: $transactionId,
    productId: $productId
  }) {
    id
    date
    country
    currency
    accountId
    merchantId
    lineItems {
      productId
      quantity
      price
      discountedPrice
      totalPrice
    }
  }
}'

class TransactionFlowsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_sample_user
  end

  test "Should create transaction" do
    user = sign_in_as_sample_user
    account = create(:account, user: user)
    merchant = create(:merchant, user: user)

    post "/graphql", params: {
      query: CREATE_TRANSACTION_MUTATION,
      variables: {
        date: Time.utc(2023, 12, 1, 10, 0, 0, 0).iso8601,
        accountId: account.id,
        merchantId: merchant.id
      }
    }, as: :json

    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("createTransaction")
    assert_not_nil transaction
    assert_not_empty transaction["id"]
    assert_equal account.currency, transaction["currency"]
    assert_equal merchant.country, transaction["country"]
    assert_equal "2023-12-01T10:00:00Z", transaction["date"]
    assert_equal account.id, transaction["accountId"]
    assert_equal merchant.id, transaction["merchantId"]
  end

  test "Should get transaction" do
    user = sign_in_as_sample_user
    sample_product_pieces = create(:product, user: user, quantity_type: 'per_piece')
    sample_product_weighted = create(:product, user: user, quantity_type: 'weighted')

    sample_transaction = create(:transaction, user: user)
    line_item_pieces = create(:transaction_line_item,
                              owner_transaction: sample_transaction,
                              product: sample_product_pieces,
                              discounted_price_cents: nil)
    line_item_weighted = create(:transaction_line_item,
                                owner_transaction: sample_transaction,
                                product: sample_product_weighted)

    post "/graphql", params: {
      query: GET_TRANSACTION_QUERY,
      variables: { id: sample_transaction.id }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("transaction")
    assert_not_nil transaction
    assert_equal sample_transaction.id, transaction["id"]
    assert_equal sample_transaction.currency, transaction["currency"]
    assert_equal sample_transaction.country, transaction["country"]
    assert_equal sample_transaction.date.iso8601, transaction["date"]
    assert_equal sample_transaction.account_id, transaction["accountId"]
    assert_equal sample_transaction.merchant_id, transaction["merchantId"]

    assert_not_nil transaction["lineItems"]
    assert_not_empty transaction["lineItems"]
    assert_equal 2, transaction["lineItems"].length

    product_pieces = transaction["lineItems"].find { |p| p["productId"] == sample_product_pieces.id }
    assert_not_nil product_pieces
    assert_equal line_item_pieces.quantity_pieces, product_pieces["quantity"]
    assert_equal line_item_pieces.price_cents, product_pieces["price"] * 100
    assert_nil product_pieces["discountedPrice"]
    assert_equal line_item_pieces.total_price_cents, product_pieces["totalPrice"] * 100

    product_weighted = transaction["lineItems"].find { |p| p["productId"] == sample_product_weighted.id }
    assert_not_nil product_weighted
    assert_equal line_item_weighted.quantity_weighted, product_weighted["quantity"]
    assert_equal line_item_weighted.price_cents, product_weighted["price"] * 100
    assert_equal line_item_weighted.discounted_price_cents, product_weighted["discountedPrice"] * 100
    assert_equal line_item_weighted.total_price_cents, product_weighted["totalPrice"] * 100
  end

  test "Should get all transactions" do
    user = sign_in_as_sample_user
    sample_product_pieces = create(:product, user: user, quantity_type: 'per_piece')
    sample_product_weighted = create(:product, user: user, quantity_type: 'weighted')

    sample_transaction_1 = create(:transaction, user: user)

    sample_transaction_2 = create(:transaction, user: user)
    line_item_pieces = create(
      :transaction_line_item,
      owner_transaction: sample_transaction_2,
      product: sample_product_pieces,
      discounted_price_cents: nil)
    line_item_weighted = create(
      :transaction_line_item,
      owner_transaction: sample_transaction_2,
      product: sample_product_weighted)

      post "/graphql", params: { query: GET_TRANSACTIONS_LIST_QUERY }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transactions = response.parsed_body&.[]("data")&.[]("transactions")&.[]("nodes")
    assert_not_nil transactions
    assert_equal 2, transactions.length

    transaction1 = transactions.find { |p| p["id"] == sample_transaction_1.id }
    assert_not_nil transaction1
    assert_equal sample_transaction_1.currency, transaction1["currency"]
    assert_equal sample_transaction_1.country, transaction1["country"]
    assert_equal sample_transaction_1.date.iso8601, transaction1["date"]
    assert_equal sample_transaction_1.account_id, transaction1["accountId"]
    assert_equal sample_transaction_1.merchant_id, transaction1["merchantId"]

    transaction2 = transactions.find { |p| p["id"] == sample_transaction_2.id }
    assert_not_nil transaction2
    assert_equal sample_transaction_2.currency, transaction2["currency"]
    assert_equal sample_transaction_2.country, transaction2["country"]
    assert_equal sample_transaction_2.date.iso8601, transaction2["date"]
    assert_equal sample_transaction_2.account_id, transaction2["accountId"]
    assert_equal sample_transaction_2.merchant_id, transaction2["merchantId"]

    assert_not_nil transaction2["lineItems"]
    assert_not_empty transaction2["lineItems"]
    assert_equal 2, transaction2["lineItems"].length

    product_pieces = transaction2["lineItems"].find { |p| p["productId"] == sample_product_pieces.id }
    assert_not_nil product_pieces
    assert_equal line_item_pieces.quantity_pieces, product_pieces["quantity"]
    assert_equal line_item_pieces.price_cents, product_pieces["price"] * 100
    assert_nil product_pieces["discountedPrice"]
    assert_equal line_item_pieces.total_price_cents, product_pieces["totalPrice"] * 100

    product_weighted = transaction2["lineItems"].find { |p| p["productId"] == sample_product_weighted.id }
    assert_not_nil product_weighted
    assert_equal line_item_weighted.quantity_weighted, product_weighted["quantity"]
    assert_equal line_item_weighted.price_cents, product_weighted["price"] * 100
    assert_equal line_item_weighted.discounted_price_cents, product_weighted["discountedPrice"] * 100
    assert_equal line_item_weighted.total_price_cents, product_weighted["totalPrice"] * 100
  end

  test "Should update and save transaction" do
    user = sign_in_as_sample_user
    sample_transaction = create(:transaction, user: user)

    post "/graphql", params: {
      query: UPDATE_TRANSACTION_MUTATION,
      variables: { id: sample_transaction.id, new_date: Time.utc(2023, 9, 1, 13, 0, 0, 0).iso8601 }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("updateTransaction")
    assert_not_nil transaction
    assert_equal sample_transaction.id, transaction["id"]
    assert_equal sample_transaction.currency, transaction["currency"]
    assert_equal sample_transaction.country, transaction["country"]
    assert_equal "2023-09-01T13:00:00Z", transaction["date"]
    assert_equal sample_transaction.account_id, transaction["accountId"]
    assert_equal sample_transaction.merchant_id, transaction["merchantId"]

    # Test that "GetTransaction" returns the new data
    post "/graphql", params: { query: GET_TRANSACTION_QUERY, variables: { id: sample_transaction.id } }

    transaction = response.parsed_body["data"]["transaction"]
    assert_equal "2023-09-01T13:00:00Z", transaction["date"]
  end

  test "Should add a line item" do
    user = sign_in_as_sample_user
    product = create(:product, user: user, quantity_type: 'weighted')
    sample_transaction = create(:transaction, user: user)

    post "/graphql", params: {
      query: ADD_LINE_ITEM_MUTATION,
      variables: {
        transactionId: sample_transaction.id,
        productId: product.id,
        quantity: 2.5,
        price: 50,
        discountedPrice: 40.6,
        totalPrice: 101.5
      }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("addTransactionLineItem")
    assert_not_nil transaction
    assert_equal sample_transaction.id, transaction["id"]
    assert_not_empty transaction["lineItems"]
    assert_equal 1, transaction["lineItems"].length

    line_item = transaction["lineItems"][0]
    assert_equal product.id, line_item["productId"]
    assert_equal 2.5, line_item["quantity"]
    assert_equal 50, line_item["price"]
    assert_equal 40.6, line_item["discountedPrice"]
    assert_equal 101.5, line_item["totalPrice"]

    # Test that "GetTransaction" returns the new data
    post "/graphql", params: { query: GET_TRANSACTION_QUERY, variables: { id: sample_transaction.id } }
    transaction = response.parsed_body&.[]("data")&.[]("transaction")
    assert_not_empty transaction["lineItems"]
    assert_equal 1, transaction["lineItems"].length

    line_item = transaction["lineItems"][0]
    assert_equal product.id, line_item["productId"]
    assert_equal 2.5, line_item["quantity"]
    assert_equal 50, line_item["price"]
    assert_equal 40.6, line_item["discountedPrice"]
    assert_equal 101.5, line_item["totalPrice"]
  end

  test "Should update a line item" do
    user = sign_in_as_sample_user
    sample_product_pieces = create(:product, user: user, quantity_type: 'per_piece')
    sample_product_weighted = create(:product, user: user, quantity_type: 'weighted')

    sample_transaction = create(:transaction, user: user) do |t|
      create(:transaction_line_item, owner_transaction: t, product: sample_product_pieces)

      create(:transaction_line_item, owner_transaction: t, product: sample_product_weighted)
    end

    post "/graphql", params: {
      query: UPDATE_LINE_ITEM_MUTATION,
      variables: {
        transactionId: sample_transaction.id,
        productId: sample_product_weighted.id,
        quantity: 2.5,
        price: 50,
        discountedPrice: 40.6,
        totalPrice: 101.5
      }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("updateTransactionLineItem")
    assert_not_nil transaction
    assert_equal sample_transaction.id, transaction["id"]
    assert_not_empty transaction["lineItems"]

    line_item = transaction["lineItems"].find { |li| li["productId"] == sample_product_weighted.id }
    assert_equal 2.5, line_item["quantity"]
    assert_equal 50, line_item["price"]
    assert_equal 40.6, line_item["discountedPrice"]
    assert_equal 101.5, line_item["totalPrice"]

    # Test that "GetTransaction" returns the new data
    post "/graphql", params: { query: GET_TRANSACTION_QUERY, variables: { id: sample_transaction.id } }
    transaction = response.parsed_body&.[]("data")&.[]("transaction")
    line_item = transaction["lineItems"].find { |li| li["productId"] == sample_product_weighted.id }
    assert_equal 2.5, line_item["quantity"]
    assert_equal 50, line_item["price"]
    assert_equal 40.6, line_item["discountedPrice"]
    assert_equal 101.5, line_item["totalPrice"]
  end

  test "Should remove a line item" do
    user = sign_in_as_sample_user
    sample_product_pieces = create(:product, user: user, quantity_type: 'per_piece')
    sample_product_weighted = create(:product, user: user, quantity_type: 'weighted')

    sample_transaction = create(:transaction, user: user) do |t|
      create(:transaction_line_item, owner_transaction: t, product: sample_product_pieces)

      create(:transaction_line_item, owner_transaction: t, product: sample_product_weighted)
    end

    post "/graphql", params: {
      query: REMOVE_LINE_ITEM_MUTATION,
      variables: {
        transactionId: sample_transaction.id,
        productId: sample_product_weighted.id
      }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("removeTransactionLineItem")
    assert_not_nil transaction
    assert_equal sample_transaction.id, transaction["id"]
    assert_not_empty transaction["lineItems"]

    line_item = transaction["lineItems"].find { |li| li["productId"] == sample_product_weighted.id }
    assert_nil line_item

    # Test that "GetTransaction" returns the new data
    post "/graphql", params: { query: GET_TRANSACTION_QUERY, variables: { id: sample_transaction.id } }
    transaction = response.parsed_body&.[]("data")&.[]("transaction")
    line_item = transaction["lineItems"].find { |li| li["productId"] == sample_product_weighted.id }
    assert_nil line_item
  end

  test "Should resolve referenced objects" do
    user = sign_in_as_sample_user
    sample_product_pieces = create(:product, user: user, quantity_type: 'per_piece')
    sample_product_weighted = create(:product, user: user, quantity_type: 'weighted')

    sample_transaction_1 = create(:transaction, user: user)

    sample_transaction_2 = create(:transaction, user: user) do |t|
      create(:transaction_line_item, owner_transaction: t, product: sample_product_pieces)

      create(:transaction_line_item, owner_transaction: t, product: sample_product_weighted)
    end

    post "/graphql", params: {
      query: GET_TRANSACTIONS_LIST_QUERY_REFERENCED_OBJECTS,
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transactions = response.parsed_body&.[]("data")&.[]("transactions")&.[]("nodes")
    assert_not_nil transactions

    transaction1 = transactions.find { |t| t["id"] == sample_transaction_1.id }
    transaction1_account = transaction1["account"]
    assert_not_nil transaction1_account
    assert_equal sample_transaction_1.account.id, transaction1_account["id"]
    assert_equal sample_transaction_1.account.name, transaction1_account["name"]
    assert_equal sample_transaction_1.account.currency, transaction1_account["currency"]

    transaction1_merchant = transaction1["merchant"]
    assert_not_nil transaction1_merchant
    assert_equal sample_transaction_1.merchant.id, transaction1_merchant["id"]
    assert_equal sample_transaction_1.merchant.name, transaction1_merchant["name"]
    assert_equal sample_transaction_1.merchant.country, transaction1_merchant["country"]

    transaction2 = transactions.find { |t| t["id"] == sample_transaction_2.id }
    transaction2_account = transaction2["account"]
    assert_not_nil transaction2_account
    assert_equal sample_transaction_2.account.id, transaction2_account["id"]
    assert_equal sample_transaction_2.account.name, transaction2_account["name"]
    assert_equal sample_transaction_2.account.currency, transaction2_account["currency"]

    transaction2_merchant = transaction2["merchant"]
    assert_not_nil transaction2_merchant
    assert_equal sample_transaction_2.merchant.id, transaction2_merchant["id"]
    assert_equal sample_transaction_2.merchant.name, transaction2_merchant["name"]
    assert_equal sample_transaction_2.merchant.country, transaction2_merchant["country"]

    line_items = transaction2["lineItems"]
    product1 = line_items.find { |li| li["productId"] == sample_product_pieces.id }&.[]("product")
    assert_equal sample_product_pieces.name, product1["name"]
    assert_equal sample_product_pieces.country, product1["country"]
    assert_equal sample_product_pieces.quantity_type.upcase, product1["quantityType"]

    product2 = line_items.find { |li| li["productId"] == sample_product_weighted.id }&.[]("product")
    assert_equal sample_product_weighted.name, product2["name"]
    assert_equal sample_product_weighted.country, product2["country"]
    assert_equal sample_product_weighted.quantity_type.upcase, product2["quantityType"]
  end
end
