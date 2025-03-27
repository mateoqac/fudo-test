# frozen_string_literal: true

require 'json'
require 'rack'
require 'jwt'
require_relative 'router'

class App
  def initialize
    @router = Router.new
  end

  def call(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new
    response['Content-Type'] = 'application/json'

    @router.route(request, response)

    response.finish
  end
end
