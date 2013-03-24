require 'rest_client'
require 'json'
require 'securerandom'

module Cloud
  module Agent
    require_relative 'agent/version'
    require_relative 'agent/authentication'
    require_relative 'agent/deploy'
    require_relative 'agent/errors'
    require_relative 'agent/logger'

    def self.endpoint
      'https://api.cloud.com/v1'
    end

    def self.logger
      Cloud::Agent::Logger.new('./logs/cloud-agent.log')
    end
  end
end
