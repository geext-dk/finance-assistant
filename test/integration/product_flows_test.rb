require "test_helper"

CREATE_PRODUCT_QUERY = '
mutation createProductMutation($name: String!, $country: String!, $quantity_type: QuantityType!) {
  createProduct(input: { name: $name, country: $country, quantityType: $quantity_type }) {
    id
    name
    country
    quantityType
  }
}
'

GET_PRODUCT_QUERY = '
query getProductQuery($id: ID!) {
  product(id: $id) {
    id
    name
    country
    quantityType
  }
}
'

GET_PRODUCTS_LIST_QUERY = '
query getProductsListQuery {
  products {
    nodes {
      id
      name
      quantityType
      country
    }
  }
}
'

UPDATE_PRODUCT_QUERY = '
mutation updateProductMutation($id: ID!, $new_name: String!) {
  updateProduct(input: {productId: $id, name: $new_name}) {
    id
    name
    country
    quantityType
  }
}
'

ARCHIVE_PRODUCT_QUERY = '
mutation archiveProductMutation($id: ID!) {
  archiveProduct(input: {productId: $id}) {
    id
    name
    country
    quantityType
  }
}'

class ProductFlowsTest < ActionDispatch::IntegrationTest
  test "Should create product" do
    sign_in_as_sample_user

    post "/graphql", params: {
      query: CREATE_PRODUCT_QUERY,
      variables: {
        name: "Integration test product",
        country: "SE",
        quantity_type: "PER_PIECE"
      }
    }

    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    create_product = response.parsed_body&.[]("data")&.[]("createProduct")
    assert_not_nil create_product
    assert_not_empty create_product["id"]
  end

  test "Should get product" do
    user = sign_in_as_sample_user
    sample_product = create(:product, user: user)

    post "/graphql", params: { query: GET_PRODUCT_QUERY, variables: { id: sample_product.id } }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    product = response.parsed_body&.[]("data")&.[]("product")
    assert_not_nil product
    assert_equal sample_product.id, product["id"]
    assert_equal sample_product.name, product["name"]
    assert_equal sample_product.country, product["country"]
    assert_equal sample_product.quantity_type, product["quantityType"].downcase
  end

  test "Should get all products" do
    user = sign_in_as_sample_user
    sample_product = create(:product, user: user)

    post "/graphql", params: { query: GET_PRODUCTS_LIST_QUERY }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    products = response.parsed_body&.[]("data")&.[]("products")&.[]("nodes")
    assert_not_nil products
    assert_not_empty products

    products_by_id = products.select { |p| p["id"] == sample_product.id }
    assert_not_nil products_by_id
    assert_equal 1, products_by_id.length

    product_from_products = products_by_id[0]
    assert_equal sample_product.name, product_from_products["name"]
    assert_equal sample_product.country, product_from_products["country"]
    assert_equal sample_product.quantity_type, product_from_products["quantityType"].downcase
  end

  test "Should update and save product" do
    user = sign_in_as_sample_user
    sample_product = create(:product, user: user)

    post "/graphql", params: {
      query: UPDATE_PRODUCT_QUERY,
      variables: { id: sample_product.id, new_name: "New Sample product 1 name" }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    product = response.parsed_body&.[]("data")&.[]("updateProduct")
    assert_not_nil product
    assert_equal sample_product.id, product["id"]
    assert_equal "New Sample product 1 name", product["name"]
    assert_equal sample_product.country, product["country"]
    assert_equal sample_product.quantity_type, product["quantityType"].downcase

    # Test that "GetProduct" returns the new data
    post "/graphql", params: { query: GET_PRODUCT_QUERY, variables: { id: sample_product.id } }, as: :json

    product = response.parsed_body["data"]["product"]
    assert_equal "New Sample product 1 name", product["name"]
  end

  test "Should archive product" do
    user = sign_in_as_sample_user
    sample_product = create(:product, user: user)

    post "/graphql", params: {
      query: ARCHIVE_PRODUCT_QUERY,
      variables: { id: sample_product.id }
    }, as: :json
    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    product = response.parsed_body&.[]("data")&.[]("archiveProduct")
    assert_not_nil product
    assert_equal sample_product.id, product["id"]
    assert_equal sample_product.name, product["name"]
    assert_equal sample_product.country, product["country"]
    assert_equal sample_product.quantity_type, product["quantityType"].downcase

    # Test that "GetProduct" does not return this product anymore
    post "/graphql", params: { query: GET_PRODUCT_QUERY, variables: { id: sample_product.id } }, as: :json
    assert_response :success
    assert_not_nil response.parsed_body&.[]("data")
    assert_nil response.parsed_body["data"]["product"]
    assert_not_nil response.parsed_body&.[]("errors")
    assert_not_empty response.parsed_body["errors"]
  end
end
