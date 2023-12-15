require "test_helper"

REGISTER_USER_MUTATION = '
mutation registerUserMutation($email: String!, $password: String!) {
  register(input: { email: $email, password: $password, passwordConfirmation: $password }) {
    id
    email
  }
}'

LOGIN_USER_MUTATION = '
mutation loginUserMutation($email: String!, $password: String!) {
  login(input: { email: $email, password: $password }) {
    id
    email
  }
}
'

class UserFlowsTest < ActionDispatch::IntegrationTest
  test "Should register user" do
    post "/graphql", params: {
      query: REGISTER_USER_MUTATION,
      variables: {
        email: "some-email@example.com",
        password: "somepassword"
      }
    }, as: :json

    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    user = response.parsed_body&.[]("data")&.[]("register")
    assert_not_nil user
    assert_not_empty user["id"]
    assert_equal "some-email@example.com", user["email"]
  end

  test "Should login" do
    post "/graphql", params: {
      query: LOGIN_USER_MUTATION,
      variables: {
        email: "test@example.com",
        password: "somepassword"
      }
    }

    puts response.body
    assert_response :success
    assert_nil response.parsed_body&.[]("errors")

    user = response.parsed_body&.[]("data")&.[]("login")
    assert_not_nil user
    assert_not_empty user["id"]
    assert_equal "test@example.com", user["email"]
  end
end
