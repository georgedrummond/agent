require 'test_helper'

class DeployTest < MiniTest::Unit::TestCase

  def test_having_an_exception_raised
    request = stub_request(:post, 'https://api.cloud.com/v1/exceptions').to_return(:status => 201)
    stub_request(:get, 'https://api.cloud.com/v1/deploys/error').to_return(:status => [404, 'not found'])
    deploy = Cloud::Agent::Deploy.new('error')
    deploy.request_payload!

    assert_requested(request, :times => 1)
  end
end