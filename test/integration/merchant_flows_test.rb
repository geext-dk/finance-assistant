require "test_helper"

CREATE_MERCHANT_QUERY = '
mutation createMerchantMutation($name: String!, $country: String!) {
  createMerchant(input: { name: $name, country: $country }) {
    id
    name
    country
  }
}
'

GET_MERCHANT_QUERY = '
query getMerchantQuery($id: ID!) {
  merchant(id: $id) {
    id
    name
    country
  }
}
'

GET_MERCHANTS_LIST_QUERY = '
query getMerchantsListQuery {
  merchants {
    nodes {
      id
      name
      country
    }
  }
}
'

UPDATE_MERCHANT_QUERY = '
mutation updateMerchantMutation($id: ID!, $new_name: String!) {
  updateMerchant(input: {merchantId: $id, name: $new_name}) {
    id
    name
    country
  }
}
'

ARCHIVE_MERCHANT_QUERY = '
mutation archiveMerchantMutation($id: ID!) {
  archiveMerchant(input: {merchantId: $id}) {
    id
    name
    country
  }
}
'

MERCHANT_ID = "a8a1ccc9-ad5d-47d2-a7f9-f14deeeaa001"

class MerchantFlowsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_sample_user
  end

  test "Should create merchant" do
    post "/graphql", params: {
      query: CREATE_MERCHANT_QUERY,
      variables: {
        name: "Integration test merchant",
        country: "SE"
      }
    }, as: :json

    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    merchant = response.parsed_body&.[]("data")&.[]("createMerchant")
    assert_not_nil merchant
    assert_not_empty merchant["id"]
    assert_equal "Integration test merchant", merchant["name"]
    assert_equal "SE", merchant["country"]
  end

  test "Should get merchant" do
    post "/graphql", params: { query: GET_MERCHANT_QUERY, variables: { id: MERCHANT_ID } }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    merchant = response.parsed_body&.[]("data")&.[]("merchant")
    assert_not_nil merchant
    assert_equal MERCHANT_ID, merchant["id"]
    assert_equal "Sample merchant 1", merchant["name"]
    assert_equal "SE", merchant["country"]
  end

  test "Should get all merchants" do
    post "/graphql", params: { query: GET_MERCHANTS_LIST_QUERY }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    merchants = response.parsed_body&.[]("data")&.[]("merchants")&.[]("nodes")
    assert_not_nil merchants
    assert_not_empty merchants

    merchants_by_id = merchants.select { |p| p["id"] == MERCHANT_ID }
    assert_not_nil merchants_by_id
    assert_equal 1, merchants_by_id.length

    merchant_from_merchants = merchants_by_id[0]
    assert_equal MERCHANT_ID, merchant_from_merchants["id"]
    assert_equal "Sample merchant 1", merchant_from_merchants["name"]
    assert_equal "SE", merchant_from_merchants["country"]
  end

  test "Should update and save merchant" do
    post "/graphql", params: {
      query: UPDATE_MERCHANT_QUERY,
      variables: { id: MERCHANT_ID, new_name: "New Sample merchant 1 name" }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    merchant = response.parsed_body&.[]("data")&.[]("updateMerchant")
    assert_not_nil merchant
    assert_equal MERCHANT_ID, merchant["id"]
    assert_equal "New Sample merchant 1 name", merchant["name"]
    assert_equal "SE", merchant["country"]

    # Test that "GetMerchant" returns the new data
    post "/graphql", params: { query: GET_MERCHANT_QUERY, variables: { id: MERCHANT_ID } }, as: :json

    merchant = response.parsed_body["data"]["merchant"]
    assert_equal "New Sample merchant 1 name", merchant["name"]
  end

  test "Should archive merchant" do
    post "/graphql", params: {
      query: ARCHIVE_MERCHANT_QUERY,
      variables: { id: MERCHANT_ID }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    merchant = response.parsed_body&.[]("data")&.[]("archiveMerchant")
    assert_not_nil merchant
    assert_equal MERCHANT_ID, merchant["id"]
    assert_equal "Sample merchant 1", merchant["name"]
    assert_equal "SE", merchant["country"]

    # Test that "GetMerchant" does not return this merchant anymore
    post "/graphql", params: { query: GET_MERCHANT_QUERY, variables: { id: MERCHANT_ID } }, as: :json
    assert_response :success
    assert_not_nil response.parsed_body&.[]("data")
    assert_nil response.parsed_body["data"]["merchant"]
    assert_not_nil response.parsed_body&.[]("errors")
    assert_not_empty response.parsed_body["errors"]
  end
end
