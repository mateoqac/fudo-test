# frozen_string_literal: true

require 'spec_helper'

describe AuthMiddleware do
  let(:app) { double('app', call: [200, {}, []]) }
  let(:middleware) { AuthMiddleware.new(app) }

  it 'permite solicitudes no protegidas' do
    env = Rack::MockRequest.env_for('/openapi.yaml')
    expect(app).to receive(:call).with(env)
    middleware.call(env)
  end

  it 'rechaza solicitudes protegidas sin token' do
    env = Rack::MockRequest.env_for('/products', method: 'POST')
    response = middleware.call(env)
    expect(response[0]).to eq(401)
  end

  it 'valida token correctamente' do
    stub_env('TOKEN_SECRET', 'custom_secret')
    token = JWT.encode({ user: 'admin' }, Config.token_secret, 'HS256')
    env = Rack::MockRequest.env_for('/products',
                                    method: 'POST',
                                    'HTTP_AUTHORIZATION' => "Bearer #{token}")
    expect(app).to receive(:call).with(env)
    middleware.call(env)
  end
end
