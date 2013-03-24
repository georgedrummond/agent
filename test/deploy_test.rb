require 'test_helper'

class DeployTest < MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest

  def setup
    FileUtils.remove_dir(ENV['DEPLOYMENT_PATH']) rescue nil
    FileUtils.mkdir_p(ENV['DEPLOYMENT_PATH'])
    FileUtils.mkdir_p File.join(ENV['DEPLOYMENT_PATH'], 'tmp')
    FileUtils.mkdir_p File.join(ENV['DEPLOYMENT_PATH'], 'releases')
  end

  def test_requesting_payload_returns_an_unexpected_error
    stub_request(:get, 'https://api.cloud.com/v1/deploys/abcd').to_return(:status => [500, 'Internal Error'])
    mock(Cloud::Agent::Error).notify('request_payload_invalid_response', anything).once
    deploy = Cloud::Agent::Deploy.new('abcd')
    deploy.request_payload!

    assert_equal deploy.response, nil
  end

  def test_requesting_payload_returns_a_200_response
    deploy_setup
    @deploy.request_payload!

    assert_equal @deploy.appname,    'cloud-agent'
    assert_equal @deploy.deployment, 'cloud-agent-3msd893'
    assert_equal @deploy.archive_url, archive_url
  end

  def test_downloading_archived_deployment_unexpected_error
    stubbed_deploy_response
    stub_request(:get, @archive_url).to_return(:status => [404, 'File Not Found'])
    mock(Cloud::Agent::Error).notify('download_deployment_archive_error', anything).once
    deploy = Cloud::Agent::Deploy.new('abcd')
    deploy.request_payload!
    deploy.download_deployment_archive!

    assert !File.exists?(deploy.archive_download_path)
  end

  def test_downloading_archived_deployment
    deploy_setup
    @deploy.request_payload!
    @deploy.download_deployment_archive!

    assert File.exists? @deploy.archive_download_path
    assert FileUtils.compare_file dummy_archive_path, @deploy.archive_download_path
  end

  def test_unpackaging_downloaded_archive
    deploy_setup
    @deploy.request_payload!
    @deploy.download_deployment_archive!
    @deploy.unpackage_deployment_archive!

    assert !File.exists?(@deploy.archive_download_path)
    assert File.directory? @deploy.latest_release_path
    assert File.exists? File.join(@deploy.latest_release_path, 'Gemfile')
  end

  def test_symlinking_current
    deploy_setup
    @deploy.request_payload!
    @deploy.download_deployment_archive!
    @deploy.unpackage_deployment_archive!
    @deploy.symlink_current!

    assert File.symlink?(@deploy.current_release_path)
  end

private

  def dummy_archive_path
    File.join(Dir.pwd, 'test/support/archive.tar.gz')
  end

  def dummy_archive
    File.open(dummy_archive_path, 'rb').read
  end

  def deploy_setup
    stubbed_deploy_response
    stub_request(:get, @archive_url).to_return(:status => 200, :body => dummy_archive)
    @deploy = Cloud::Agent::Deploy.new('abcd')
  end

  def stubbed_deploy_response
    stub_request(:get, 'https://api.cloud.com/v1/deploys/abcd').to_return(:body => response_json, :status => 200)
  end

  def archive_url
    @archive_url ||= "https://s3.amazonaws.com/cloud-agent/cloud-agent/cloud-agent-3msd893.tar.gz?secure_token=#{SecureRandom.hex(20)}"
  end

  def response_json
    {
      :deployment  => 'cloud-agent-3msd893',
      :appname     => 'cloud-agent',
      :archive_url => archive_url,
      :timestamp   => Time.now.to_i,
      :servername  => 'bluesky8893'
    }.to_json
  end
end