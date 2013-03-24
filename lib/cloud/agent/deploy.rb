require 'open-uri'
require 'zlib'

class Cloud::Agent::Deploy
  include Cloud::Agent::Authentication

  attr_reader :deploy_token

  def initialize(deploy_token)
    @deploy_token = deploy_token
  end

  def archive_download_path
    File.join(ENV['DEPLOYMENT_PATH'], "/tmp/#{deployment}.tar.gz")
  end

  def releases_path
    File.join(ENV['DEPLOYMENT_PATH'], 'releases')
  end

  def latest_release_path
    File.join(releases_path, deployment)
  end

  def current_release_path
    File.join(ENV['DEPLOYMENT_PATH'], 'current')
  end

  def request_payload!
    path = "/deploys/#{@deploy_token}"
    response = JSON.parse authenticated_request(:get, path)
    response.each { |k, v| self.class.send :define_method, k, proc {v} }
    Cloud::Agent.logger.info(['deploy_response', path, response])
  rescue => e
    Cloud::Agent::Error.notify('request_payload_invalid_response', e)
  end

  def download_deployment_archive!
    File.open(archive_download_path, 'wb') do |deployment_archive|
      open(archive_url) do |archive_download|
        deployment_archive.write archive_download.read
        Cloud::Agent.logger.info(['download_deployment_archive', archive_url, archive_download_path])
      end
    end
  rescue => e
    File.delete(archive_download_path)
    Cloud::Agent::Error.notify('download_deployment_archive_error', e) 
  end

  def unpackage_deployment_archive!
    `mkdir #{latest_release_path} && tar zxf #{archive_download_path} -C #{latest_release_path}`
    Cloud::Agent.logger.info(['extracted_deployment_archive', latest_release_path])
    File.delete(archive_download_path)
    Cloud::Agent.logger.info(['cleanup_deployment_archive', archive_download_path])
  end

  def symlink_current!
    File.symlink latest_release_path, current_release_path
  end
end
