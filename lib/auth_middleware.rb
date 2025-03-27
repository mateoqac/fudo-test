# frozen_string_literal: true

require 'jwt'
require_relative 'config'

class AuthMiddleware
  class InvalidToken < StandardError; end

  def initialize(app, protected_paths = ['/products'])
    @app = app
    @protected_paths = protected_paths
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) unless protected_path?(request.path)

    auth_header = env['HTTP_AUTHORIZATION']
    unless auth_header&.start_with?('Bearer ')
      return [401, { 'Content-Type' => 'application/json' },
              [{ error: 'Se requiere autenticación' }.to_json]]
    end

    token = auth_header.split.last
    begin
      JWT.decode(token, Config.token_secret, true, algorithm: 'HS256')
      @app.call(env)
    rescue JWT::DecodeError
      [401, { 'Content-Type' => 'application/json' },
       [{ error: 'Token inválido' }.to_json]]
    end
  end

  private

  def protected_path?(path)
    @protected_paths.any? { |protected_path| path.start_with?(protected_path) }
  end
end
