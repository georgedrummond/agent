require 'open-uri'
require 'zlib'

class Cloud::Agent::Deploy
  include Cloud::Agent::Authentication

  attr_reader :deploy_token, :response, :archive_download_path, :release_path

  def initialize(deploy_token)
    @deploy_token = deploy_token
  end

  def appname
    @response['appname']
  end

  def archive_url
    @response['archive_url']
  end

  def deployment
    @response['deployment']
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
    url = "https://api.cloud.com/v1/deploys/#{@deploy_token}"
    @response = JSON.parse authenticated_request(url)
    Cloud::Agent.logger.info(['deploy_response', url, response])
  rescue => e
    Cloud::Agent::Exception.notify('request_payload_invalid_response', e)
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
    Cloud::Agent::Exception.notify('download_deployment_archive_error', e) 
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
