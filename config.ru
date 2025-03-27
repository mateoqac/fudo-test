# frozen_string_literal: true

require 'dotenv/load'
require 'rack/deflater'
require_relative 'lib/app'
require_relative 'lib/auth_middleware'

use Rack::Deflater
use AuthMiddleware, ['/products']
run App.new
