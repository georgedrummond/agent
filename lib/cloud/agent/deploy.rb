require 'open-uri'
require 'zlib'

class Cloud::Agent::Deploy
  include Cloud::Agent::Authentication

  attr_reader :deploy_token

  def initialize(deploy_token)
    @deploy_token = deploy_token
  end

  def app_path
    File.join(ENV['DEPLOYMENT_PATH'], appname)
  end

  def archive_download_path
    File.join(app_path, "/tmp/#{deployment}.tar.gz")
  end

  def releases_path
    File.join(app_path, 'releases')
  end

  def latest_release_path
    File.join(releases_path, deployment)
  end

  def current_release_path
    File.join(app_path, 'current')
  end

  def request_payload!
    path = "/deploys/#{@deploy_token}"
    response = JSON.parse authenticated_request(:get, path)
    response.each { |k, v| self.class.send :define_method, k, proc {v} }
    log.info ['deploy_response', path, response]
  rescue => e
    report_error 'request_payload_invalid_response', e
  end

  def download_deployment_archive!
    File.open(archive_download_path, 'wb') do |deployment_archive|
      open(archive_url) do |archive_download|
        deployment_archive.write archive_download.read
        log.info ['download_deployment_archive', archive_url, archive_download_path]
      end
    end
  rescue => e
    delete_file archive_download_path
    report_error 'download_deployment_archive_error', e
  end

  def unpackage_deployment_archive!
    `mkdir #{latest_release_path} && tar zxf #{archive_download_path} -C #{latest_release_path}`
    log.info ['extracted_deployment_archive', latest_release_path]
    delete_file archive_download_path
    log.info ['cleanup_deployment_archive', archive_download_path]
  end

  def symlink_current!
    File.symlink latest_release_path, current_release_path
  end

private

  def log
    Cloud::Agent.logger
  end

  def delete_file(path)
    File.delete(path)
  end

  def report_error(name, error)
    Cloud::Agent::Error.notify(name, error)
  end
end
