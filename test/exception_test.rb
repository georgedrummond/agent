require 'test_helper'

class DeployTest < MiniTest::Unit::TestCase

  def test_having_an_exception_raised
    stub_request(:post, 'https://api.cloud.com/v1/exceptions').to_return(:status => 201)
    ji
  rescue => e
    Cloud::Agent::Error.notify('test_exception', e)
  end
end