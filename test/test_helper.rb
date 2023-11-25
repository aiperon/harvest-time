# frozen_string_literal: true

require_relative '../lib/harvest_time'
require 'timecop'
require 'minitest/autorun'

require 'webmock'
require 'webmock/minitest'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'test/cassettes'
  config.hook_into :webmock
  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  config.filter_sensitive_data('$HARVEST_ACCESS_TOKEN') { ENV['HARVEST_ACCESS_TOKEN'] }
  config.filter_sensitive_data('$HARVEST_ACCOUNT_ID') { ENV['HARVEST_ACCOUNT_ID'] }
end
