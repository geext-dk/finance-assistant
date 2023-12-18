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

ACCOUNT_ID = "fc1d22c0-0d49-45ad-851e-ad7ab8160001"
MERCHANT_ID = "a8a1ccc9-ad5d-47d2-a7f9-f14deeeaa001"
PRODUCT_ID_PIECES = "14e057e3-e346-4424-b866-5eb55a955001"
PRODUCT_ID_WEIGHTED = "14e057e3-e346-4424-b866-5eb55a955002"
TRANSACTION_ID = "cc24b843-9452-4abc-b505-1491a645e001"
TRANSACTION_WITH_LINE_ITEMS_ID = "cc24b843-9452-4abc-b505-1491a645e002"

class TransactionFlowsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_sample_user
  end

  test "Should create transaction" do
    post "/graphql", params: {
      query: CREATE_TRANSACTION_MUTATION,
      variables: {
        date: Time.utc(2023, 12, 1, 10, 0, 0, 0).iso8601,
        accountId: ACCOUNT_ID,
        merchantId: MERCHANT_ID
      }
    }, as: :json

    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("createTransaction")
    assert_not_nil transaction
    assert_not_empty transaction["id"]
    assert_equal "EUR", transaction["currency"]
    assert_equal "SE", transaction["country"]
    assert_equal "2023-12-01T10:00:00Z", transaction["date"]
    assert_equal ACCOUNT_ID, transaction["accountId"]
    assert_equal MERCHANT_ID, transaction["merchantId"]
  end

  test "Should get transaction" do
    post "/graphql", params: {
      query: GET_TRANSACTION_QUERY,
      variables: { id: TRANSACTION_WITH_LINE_ITEMS_ID }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("transaction")
    assert_not_nil transaction
    assert_equal TRANSACTION_WITH_LINE_ITEMS_ID, transaction["id"]
    assert_equal "RSD", transaction["currency"]
    assert_equal "RS", transaction["country"]
    assert_equal "2023-12-01T12:00:00Z", transaction["date"]
    assert_equal ACCOUNT_ID, transaction["accountId"]
    assert_equal MERCHANT_ID, transaction["merchantId"]

    assert_not_nil transaction["lineItems"]
    assert_not_empty transaction["lineItems"]
    assert_equal 2, transaction["lineItems"].length

    product_pieces = transaction["lineItems"].find { |p| p["productId"] == PRODUCT_ID_PIECES }
    assert_not_nil product_pieces
    assert_equal 3, product_pieces["quantity"]
    assert_equal 10, product_pieces["price"]
    assert_equal 30, product_pieces["totalPrice"]

    product_weighted = transaction["lineItems"].find { |p| p["productId"] == PRODUCT_ID_WEIGHTED }
    assert_not_nil product_weighted
    assert_equal 2.5, product_weighted["quantity"]
    assert_equal 20, product_weighted["price"]
    assert_equal 16, product_weighted["discountedPrice"]
    assert_equal 40, product_weighted["totalPrice"]
  end

  test "Should get all transactions" do
    post "/graphql", params: { query: GET_TRANSACTIONS_LIST_QUERY }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transactions = response.parsed_body&.[]("data")&.[]("transactions")&.[]("nodes")
    assert_not_nil transactions
    assert_equal 2, transactions.length

    transaction1 = transactions.find { |p| p["id"] == TRANSACTION_ID }
    assert_not_nil transaction1
    assert_equal "EUR", transaction1["currency"]
    assert_equal "SE", transaction1["country"]
    assert_equal "2023-12-01T10:00:00Z", transaction1["date"]
    assert_equal ACCOUNT_ID, transaction1["accountId"]
    assert_equal MERCHANT_ID, transaction1["merchantId"]

    transaction2 = transactions.find { |p| p["id"] == TRANSACTION_WITH_LINE_ITEMS_ID }
    assert_not_nil transaction2
    assert_equal "RSD", transaction2["currency"]
    assert_equal "RS", transaction2["country"]
    assert_equal "2023-12-01T12:00:00Z", transaction2["date"]
    assert_equal ACCOUNT_ID, transaction2["accountId"]
    assert_equal MERCHANT_ID, transaction2["merchantId"]

    assert_not_nil transaction2["lineItems"]
    assert_not_empty transaction2["lineItems"]
    assert_equal 2, transaction2["lineItems"].length

    product_pieces = transaction2["lineItems"].find { |p| p["productId"] == PRODUCT_ID_PIECES }
    assert_not_nil product_pieces
    assert_equal 3, product_pieces["quantity"]
    assert_equal 10, product_pieces["price"]
    assert_equal 30, product_pieces["totalPrice"]

    product_weighted = transaction2["lineItems"].find { |p| p["productId"] == PRODUCT_ID_WEIGHTED }
    assert_not_nil product_weighted
    assert_equal 2.5, product_weighted["quantity"]
    assert_equal 20, product_weighted["price"]
    assert_equal 16, product_weighted["discountedPrice"]
    assert_equal 40, product_weighted["totalPrice"]
  end

  test "Should update and save transaction" do
    post "/graphql", params: {
      query: UPDATE_TRANSACTION_MUTATION,
      variables: { id: TRANSACTION_ID, new_date: Time.utc(2023, 9, 1, 13, 0, 0, 0).iso8601 }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("updateTransaction")
    assert_not_nil transaction
    assert_equal TRANSACTION_ID, transaction["id"]
    assert_equal "EUR", transaction["currency"]
    assert_equal "SE", transaction["country"]
    assert_equal "2023-09-01T13:00:00Z", transaction["date"]
    assert_equal ACCOUNT_ID, transaction["accountId"]
    assert_equal MERCHANT_ID, transaction["merchantId"]

    # Test that "GetTransaction" returns the new data
    post "/graphql", params: { query: GET_TRANSACTION_QUERY, variables: { id: TRANSACTION_ID } }

    transaction = response.parsed_body["data"]["transaction"]
    assert_equal "2023-09-01T13:00:00Z", transaction["date"]
  end

  test "Should add a line item" do
    post "/graphql", params: {
      query: ADD_LINE_ITEM_MUTATION,
      variables: {
        transactionId: TRANSACTION_ID,
        productId: PRODUCT_ID_WEIGHTED,
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
    assert_equal TRANSACTION_ID, transaction["id"]
    assert_not_empty transaction["lineItems"]
    assert_equal 1, transaction["lineItems"].length

    line_item = transaction["lineItems"][0]
    assert_equal PRODUCT_ID_WEIGHTED, line_item["productId"]
    assert_equal 2.5, line_item["quantity"]
    assert_equal 50, line_item["price"]
    assert_equal 40.6, line_item["discountedPrice"]
    assert_equal 101.5, line_item["totalPrice"]

    # Test that "GetTransaction" returns the new data
    post "/graphql", params: { query: GET_TRANSACTION_QUERY, variables: { id: TRANSACTION_ID } }
    transaction = response.parsed_body&.[]("data")&.[]("transaction")
    assert_not_empty transaction["lineItems"]
    assert_equal 1, transaction["lineItems"].length

    line_item = transaction["lineItems"][0]
    assert_equal PRODUCT_ID_WEIGHTED, line_item["productId"]
    assert_equal 2.5, line_item["quantity"]
    assert_equal 50, line_item["price"]
    assert_equal 40.6, line_item["discountedPrice"]
    assert_equal 101.5, line_item["totalPrice"]
  end

  test "Should update a line item" do
    post "/graphql", params: {
      query: UPDATE_LINE_ITEM_MUTATION,
      variables: {
        transactionId: TRANSACTION_WITH_LINE_ITEMS_ID,
        productId: PRODUCT_ID_WEIGHTED,
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
    assert_equal TRANSACTION_WITH_LINE_ITEMS_ID, transaction["id"]
    assert_not_empty transaction["lineItems"]

    line_item = transaction["lineItems"].find { |li| li["productId"] == PRODUCT_ID_WEIGHTED }
    assert_equal 2.5, line_item["quantity"]
    assert_equal 50, line_item["price"]
    assert_equal 40.6, line_item["discountedPrice"]
    assert_equal 101.5, line_item["totalPrice"]

    # Test that "GetTransaction" returns the new data
    post "/graphql", params: { query: GET_TRANSACTION_QUERY, variables: { id: TRANSACTION_WITH_LINE_ITEMS_ID } }
    transaction = response.parsed_body&.[]("data")&.[]("transaction")
    line_item = transaction["lineItems"].find { |li| li["productId"] == PRODUCT_ID_WEIGHTED }
    assert_equal 2.5, line_item["quantity"]
    assert_equal 50, line_item["price"]
    assert_equal 40.6, line_item["discountedPrice"]
    assert_equal 101.5, line_item["totalPrice"]
  end

  test "Should remove a line item" do
    post "/graphql", params: {
      query: REMOVE_LINE_ITEM_MUTATION,
      variables: {
        transactionId: TRANSACTION_WITH_LINE_ITEMS_ID,
        productId: PRODUCT_ID_WEIGHTED
      }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transaction = response.parsed_body&.[]("data")&.[]("removeTransactionLineItem")
    assert_not_nil transaction
    assert_equal TRANSACTION_WITH_LINE_ITEMS_ID, transaction["id"]
    assert_not_empty transaction["lineItems"]

    line_item = transaction["lineItems"].find { |li| li["productId"] == PRODUCT_ID_WEIGHTED }
    assert_nil line_item

    # Test that "GetTransaction" returns the new data
    post "/graphql", params: { query: GET_TRANSACTION_QUERY, variables: { id: TRANSACTION_WITH_LINE_ITEMS_ID } }
    transaction = response.parsed_body&.[]("data")&.[]("transaction")
    line_item = transaction["lineItems"].find { |li| li["productId"] == PRODUCT_ID_WEIGHTED }
    assert_nil line_item
  end

  test "Should resolve referenced object" do
    post "/graphql", params: {
      query: GET_TRANSACTIONS_LIST_QUERY_REFERENCED_OBJECTS,
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    transactions = response.parsed_body&.[]("data")&.[]("transactions")&.[]("nodes")
    assert_not_nil transactions

    transaction1 = transactions.find { |t| t["id"] == "cc24b843-9452-4abc-b505-1491a645e001" }
    transaction1_account = transaction1["account"]
    assert_not_nil transaction1_account
    assert_equal ACCOUNT_ID, transaction1_account["id"]
    assert_equal "Sample account 1", transaction1_account["name"]
    assert_equal "EUR", transaction1_account["currency"]

    transaction1_merchant = transaction1["merchant"]
    assert_not_nil transaction1_merchant
    assert_equal MERCHANT_ID, transaction1_merchant["id"]
    assert_equal "Sample merchant 1", transaction1_merchant["name"]
    assert_equal "SE", transaction1_merchant["country"]

    transaction2 = transactions.find { |t| t["id"] == "cc24b843-9452-4abc-b505-1491a645e002" }
    transaction2_account = transaction2["account"]
    assert_not_nil transaction2_account
    assert_equal ACCOUNT_ID, transaction2_account["id"]
    assert_equal "Sample account 1", transaction2_account["name"]
    assert_equal "EUR", transaction2_account["currency"]

    transaction2_merchant = transaction2["merchant"]
    assert_not_nil transaction2_merchant
    assert_equal MERCHANT_ID, transaction2_merchant["id"]
    assert_equal "Sample merchant 1", transaction2_merchant["name"]
    assert_equal "SE", transaction2_merchant["country"]

    line_items = transaction2["lineItems"]
    product1 = line_items.find { |li| li["productId"] == "14e057e3-e346-4424-b866-5eb55a955001"}&.[]("product")
    assert_equal "Sample product 1", product1["name"]
    assert_equal "SE", product1["country"]
    assert_equal "PER_PIECE", product1["quantityType"]

    product2 = line_items.find { |li| li["productId"] == "14e057e3-e346-4424-b866-5eb55a955002"}&.[]("product")
    assert_equal "Sample product 2", product2["name"]
    assert_equal "SE", product2["country"]
    assert_equal "WEIGHTED", product2["quantityType"]
  end
end
