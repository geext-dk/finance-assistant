require "test_helper"

CREATE_ACCOUNT_QUERY = '
mutation createAccountMutation($name: String!, $currency: String!) {
  createAccount(input: { name: $name, currency: $currency }) {
    id
    name
    currency
  }
}
'

GET_ACCOUNT_QUERY = '
query getAccountQuery($id: ID!) {
  account(id: $id) {
    id
    name
    currency
  }
}
'

GET_ACCOUNTS_LIST_QUERY = '
query getAccountsListQuery {
  accounts {
    nodes {
      id
      name
      currency
    }
  }
}
'

UPDATE_ACCOUNT_QUERY = '
mutation updateAccountMutation($id: ID!, $new_name: String!) {
  updateAccount(input: { accountId: $id, name: $new_name }) {
    id
    name
    currency
  }
}
'

ARCHIVE_ACCOUNT_QUERY = '
mutation archiveAccountMutation($id: ID!) {
  archiveAccount(input: { accountId: $id }) {
    id
    name
    currency
  }
}'

class AccountFlowsTest < ActionDispatch::IntegrationTest
  test "Should create account" do
    sign_in_as_sample_user

    post "/graphql", params: {
      query: CREATE_ACCOUNT_QUERY,
      variables: {
        name: "Integration test account",
        currency: "SEK"
      }
    }, as: :json

    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    account = response.parsed_body&.[]("data")&.[]("createAccount")
    assert_not_nil account
    assert_not_empty account["id"]
    assert_equal "Integration test account", account["name"]
    assert_equal "SEK", account["currency"]
  end

  test "Should get account" do
    user = sign_in_as_sample_user
    sample_account = create(:account, user: user)

    post "/graphql", params: { query: GET_ACCOUNT_QUERY, variables: { id: sample_account.id } }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    account = response.parsed_body&.[]("data")&.[]("account")
    assert_not_nil account
    assert_equal sample_account.id, account["id"]
    assert_equal sample_account.name, account["name"]
    assert_equal sample_account.currency, account["currency"]
  end

  test "Should get all accounts" do
    user = sign_in_as_sample_user
    sample_account = create(:account, user: user)

    post "/graphql", params: { query: GET_ACCOUNTS_LIST_QUERY }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    accounts = response.parsed_body&.[]("data")&.[]("accounts")&.[]("nodes")
    assert_not_nil accounts
    assert_not_empty accounts

    accounts_by_id = accounts.select { |p| p["id"] == sample_account.id }
    assert_not_nil accounts_by_id
    assert_equal 1, accounts_by_id.length

    account_from_accounts = accounts_by_id[0]
    assert_equal sample_account.name, account_from_accounts["name"]
    assert_equal sample_account.currency, account_from_accounts["currency"]
  end

  test "Should update and save account" do
    user = sign_in_as_sample_user
    sample_account = create(:account, user: user)

    post "/graphql", params: {
      query: UPDATE_ACCOUNT_QUERY,
      variables: { id: sample_account.id, new_name: "New integration test account name" }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    account = response.parsed_body&.[]("data")&.[]("updateAccount")
    assert_not_nil account
    assert_equal sample_account.id, account["id"]
    assert_equal "New integration test account name", account["name"]
    assert_equal sample_account.currency, account["currency"]

    # Test that "GetAccount" returns the new data
    post "/graphql", params: { query: GET_ACCOUNT_QUERY, variables: { id: sample_account.id } }, as: :json

    account = response.parsed_body["data"]["account"]
    assert_equal "New integration test account name", account["name"]
  end

  test "Should archive account" do
    user = sign_in_as_sample_user
    sample_account = create(:account, user: user)

    post "/graphql", params: {
      query: ARCHIVE_ACCOUNT_QUERY,
      variables: { id: sample_account.id }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    account = response.parsed_body&.[]("data")&.[]("archiveAccount")
    assert_not_nil account
    assert_equal sample_account.id, account["id"]
    assert_equal sample_account.name, account["name"]
    assert_equal sample_account.currency, account["currency"]

    # Test that "GetAccount" does not return this account anymore
    post "/graphql", params: { query: GET_ACCOUNT_QUERY, variables: { id: sample_account.id } }, as: :json
    assert_response :success
    assert_not_nil response.parsed_body&.[]("data")
    assert_nil response.parsed_body["data"]["account"]
    assert_not_nil response.parsed_body&.[]("errors")
    assert_not_empty response.parsed_body["errors"]
  end
end
