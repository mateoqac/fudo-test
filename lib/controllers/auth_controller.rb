# frozen_string_literal: true

require 'jwt'
require_relative '../config'

class AuthController
  def initialize(request, response)
    @request = request
    @response = response
  end

  def authenticate
    return unless @request.post?

    body = JSON.parse(@request.body.read)
    if valid_credentials?(body)
      token = JWT.encode({ user: body['user'] }, Config.token_secret, 'HS256')
      @response.write({ token: }.to_json)
    else
      @response.status = 401
      @response.write({ error: 'Credenciales inválidas' }.to_json)
    end
  end

  private

  def valid_credentials?(data)
    data['user'] == 'admin' && data['password'] == 'secret'
  end
end
