require 'minitest/autorun'
require 'minitest/colorize'
require 'webmock/minitest'
require 'rr'

ENV['DEPLOYMENT_PATH'] = File.join(Dir.pwd, 'tmp')
ENV['AUTH_TOKEN']      = SecureRandom.hex(30)