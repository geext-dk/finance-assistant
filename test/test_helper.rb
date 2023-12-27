ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

LOGIN_USER_MUTATION = '
mutation login($email: String!, $password: String!) {
  login(input: { email: $email, password: $password }) {
    id
  }
}
'

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def sign_in_as_sample_user
      user = create(:user)

      post "/graphql", params: {
        query: LOGIN_USER_MUTATION,
        variables: {
          email: user.email,
          password: "somepassword"
        }
      }

      user
    end
  end
end
