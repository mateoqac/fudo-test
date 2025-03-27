# frozen_string_literal: true

require 'rspec'
require 'rack/test'
require 'rack/builder'
require 'rack/deflater'
require 'timecop'
require 'json'
require 'zlib'
require 'fileutils'

require_relative '../lib/app'
require_relative '../lib/auth_middleware'
require_relative '../lib/config'
require_relative '../lib/models/product_store'
require_relative '../lib/models/product'

require_relative '../lib/controllers/auth_controller'
require_relative '../lib/controllers/products_controller'
require_relative '../lib/controllers/static_controller'
require_relative '../lib/router'

ENV['RACK_ENV'] = 'test'

module Rack
  class MockResponse
    def json
      JSON.parse(body)
    end
  end
end

module SpecHelpers
  def stub_env(key, value)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with(key, anything).and_return(value)
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include SpecHelpers
  config.before { ProductStore.new.instance_variable_set(:@products, {}) }
end
