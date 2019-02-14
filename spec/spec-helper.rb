require 'httparty'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.color_mode = true

  config.before(:all) do
    class HttpParty
      @@STATUS = {
        OK: 200,
        CREATED: 201,
        CONFLICT: 409,
        NO_CONTENT: 204,
        NOT_FOUND: 404,
        NOT_AUTHORIZED: 401
      }
      include HTTParty
      base_uri 'http://localhost:8080/'
      def self.http_status
        @@STATUS
      end
    end
  end
end