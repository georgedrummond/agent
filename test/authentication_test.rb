require 'test_helper'

class AuthenticationTest < MiniTest::Unit::TestCase
  include Cloud::Agent::Authentication

  def setup
    stub_request(:get, 'https://api.cloud.com/v1/deploys/1').to_return(:status => 200, :body => 'response')
    @request = authenticated_request(:get, '/deploys/1')
  end
  
  def test_auth_token_is_sent_in_header
    auth_token = @request.args[:headers][:auth_token]
    assert_equal auth_token, ENV['AUTH_TOKEN']
  end

  def test_requests_are_in_json_format
    request_format = @request.args[:headers][:accept]
    assert_equal request_format, 'json'
  end
end